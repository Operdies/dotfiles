#include <bsd/sys/time.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/prctl.h>

typedef struct {
	char summary[30];
	char message[CHARBUFSIZE-30-2];
	unsigned int urgency;
	struct timespec when;
	struct timespec timeout;
} notification;

enum { MSG_LOW, MSG_NORMAL, MSG_CRITICAL, MSG_LAST };
static int MSG_DURATION[MSG_LAST] = { 5, 5, 0 };
typedef struct {
	int schemes[MSG_LAST];
	int selected;
	int count;
	int max_length;
	int prev_length;
	char **icons;
	notification history[10];
} tiramisu_settings;

static char*
read_quote(char *ch, char *dest, int limit) {
#define SKIPAHEAD(ch) while ((ch) && (*ch) && (isspace(*ch) || (*ch) == '"')) ch++;
	if (!ch)
		return ch;

	// skip leading quotes
	SKIPAHEAD(ch);
	int i;
	for (i = 0; *ch && *ch != '"'; ch++, i++) {
		if (*ch == '\\') 
			ch++;
		if (*ch == '\n')
			*ch = ' ';
		if (i < limit)
			dest[i] = *ch;
	}
	dest[MIN(i, limit-1)] = 0;
#undef SKIPAHEAD
	return ch;
}

static void
pretty_elapsed(char *timestring, int n, struct timespec elapsed2) {
	const int seconds_per_day = 60*60*24;

	int elapsed = elapsed2.tv_sec;
	int i = 0;
	int d = (elapsed / seconds_per_day);
	int h = (elapsed / 3600) % 24;
	int m = (elapsed / 60) % 60;
	int s = elapsed % 60;

	if (d)
		i += snprintf(timestring+i, n-i-1, "%d %s, ", d, d == 1 ? "day" : "days");
	if (h)
		i += snprintf(timestring+i, n-i-1, "%dh", h);
	if (m)
		i += snprintf(timestring+i, n-i-1, "%dm", m);
	i += snprintf(timestring+i, n-i-1, "%ds", s);
	timestring[i] = 0;
}

static void dismiss_message(tiramisu_settings *s, int i) {
	if (i >= s->count)
		return;
	s->count = MAX(0, s->count-1);
	int to_move = s->count - i;
	if (to_move) {
		memmove(&s->history[i], &s->history[i+1], to_move * sizeof(notification));
	}
	if (s->selected != 0)
		s->selected = MAX(s->count-1, 0);
}

static int
bar_notifications(BarElementFuncArgs *data) {
	tiramisu_settings *s = (tiramisu_settings*) data->e->data;
	// If tiramisu was not started yet, start it
	if (data->e->poll_fd == 0) {
		const int READ = 0;
		const int WRITE = 1;
		int pipes[2] = {0};
		if (pipe(pipes) == -1)
			die("pipe:");
		if (fork()) {
			close(pipes[WRITE]);
			if (fcntl(pipes[READ], F_SETFL, O_NONBLOCK) == -1) 
				die("fcntl");
			data->e->poll_fd = pipes[READ];
		} else {
			close(pipes[READ]);
			dup2(pipes[WRITE], STDOUT_FILENO);
			close(pipes[WRITE]);
			// Make tiramisu die if dwm dies
			prctl(PR_SET_PDEATHSIG, SIGTERM);
			execlp("tiramisu", "tiramisu", "-s", "-o", "\"#hints\" \"#timeout\" \"#summary\" \"#body\"", NULL);
			die("exec:");
		}
	}

	struct timespec now;
	clock_gettime(CLOCK_REALTIME, &now);
	{ // clear expired notifications
		for (int i = s->count-1; i >=0; i--) {
			notification *n = &s->history[i];
			// negative 1 ms timeout is used to indicaate no timeout
			// Critical messages should never be dismissed
			if (n->urgency == MSG_CRITICAL || n->timeout.tv_nsec == -1e6)
				continue;
			if (n->timeout.tv_sec || n->timeout.tv_nsec) {
				struct timespec elapsed;
			 	timespecsub(&now, &n->when, &elapsed);
				if (timespeccmp(&n->timeout, &elapsed, <=)) {
					dismiss_message(s, i);
				}
			}
		}
	}

	int r;

	if ((r = read(data->e->poll_fd, data->e->buffer, LENGTH(data->e->buffer))) > 0) {
		notification n = { .when = now };

		char buf[50];
		char *ch = data->e->buffer;
		time_t timeout_ms;

		ch = read_quote(ch, buf, LENGTH(buf));
		if (!sscanf(buf, "urgency=0x%x,", &n.urgency)) {
			fprintf(stderr, "Failed to parse urgency from %s\n", buf);
			return 0;
		}
		ch = read_quote(ch, buf, LENGTH(buf));
		if (!sscanf(buf, "%ld", &timeout_ms)) {
			fprintf(stderr, "Failed to parse timeout from %s\n", buf);
		}
		if (timeout_ms) {
			n.timeout.tv_sec = timeout_ms / 1000;
			n.timeout.tv_nsec = (timeout_ms % 1000) * 1e6;
		} else {
			n.timeout.tv_sec = MSG_DURATION[n.urgency];
		}

		ch = read_quote(ch, n.summary, LENGTH(n.summary));
		read_quote(ch, n.message, LENGTH(n.message));


		for (char **pair = s->icons; *pair; pair += 2) {
			char *title = pair[0];
			char *icon = pair[1];
			if (title && icon && strcmp(title, n.summary) == 0) {
				strncpy(n.summary, icon, LENGTH(n.summary));
				break;
			}
		}

		// Shift the current list of messages, evicting the oldest
		// if the last message is critical, check if we can avoid evicting it
		if (s->count == LENGTH(s->history) && s->history[LENGTH(s->history)-1].urgency == MSG_CRITICAL) {
			for (int i = 0; i < LENGTH(s->history)-1; i++) {
				if (s->history[i].urgency != MSG_CRITICAL) {
					s->history[i] = s->history[LENGTH(s->history)-1];
					break;
				}
			}
		}
		memmove(&s->history[1], &s->history[0], sizeof(notification) * (LENGTH(s->history)-1));
		memcpy(&s->history[0], &n, sizeof(notification));
		s->count = MIN(s->count + 1, LENGTH(s->history));
		if (s->selected > 0)
			s->selected = MIN(s->count-1, s->selected + 1);
	}

	while ((r = read(data->e->poll_fd, data->e->buffer, LENGTH(data->e->buffer))) > 0) {
		fprintf(stderr, "Discarded %d bytes from notification: %.*s\n", r, r, data->e->buffer);
		// discard the rest of the data. It would be truncated anyway.
	}

	// reset poll_fd so tiramisu will be restarted the next time this is called
	if (r == 0) {
		fprintf(stderr, "Tiramisu exited. Will restart later.\n");
		close(data->e->poll_fd);
		data->e->poll_fd = 0;
		data->e->scheme = s->schemes[MSG_CRITICAL];
		sprintf(data->e->buffer, "Tiramisu failed to start.");
		return 1;
	}

	if (s->count == 0)
		return 0;

	int limit = CHARBUFSIZE - 1;
	if (s->max_length)
		limit = MIN(limit, s->max_length);

	notification *n = &s->history[s->selected];
	data->e->scheme = s->schemes[n->urgency];
	char timestring[100];
	struct timespec elapsed;
	timespecsub(&now, &n->when, &elapsed);

	pretty_elapsed(timestring, LENGTH(timestring), elapsed);
	int i = snprintf(data->e->buffer, CHARBUFSIZE,  "(%d/%d) %s %s (%s)", s->selected+1, s->count, n->summary, n->message, timestring);

	// truncate if needed
	if (limit && i > limit) {
		for (int i = limit - 3; i < limit; i++)
			data->e->buffer[i] = '.';
		data->e->buffer[limit] = 0;
	}

	return 1;
}

static void
bar_scroll_right (BarElementFuncArgs *data) {
	tiramisu_settings *s = (tiramisu_settings*) data->e->data;
	if (s->max_length == 0)
		return;
	s->max_length = CLAMP(s->max_length+1, 5, CHARBUFSIZE-1);
}
static void
bar_scroll_left (BarElementFuncArgs *data) {
	tiramisu_settings *s = (tiramisu_settings*) data->e->data;
	if (s->max_length == 0)
		return;
	s->max_length = CLAMP(s->max_length - 1, 5, CHARBUFSIZE-1);
}

static void
bar_toggle_shown(BarElementFuncArgs *data) {
	tiramisu_settings *s = (tiramisu_settings*) data->e->data;
	int tmp = s->prev_length;
	s->prev_length = s->max_length;
	s->max_length = tmp;
}

static void
next_notification(BarElementFuncArgs *data) {
	tiramisu_settings *s = (tiramisu_settings*) data->e->data;
	s->selected = MAX(0, s->selected - 1);
}

static void
prev_notification(BarElementFuncArgs *data) {
	tiramisu_settings *s = (tiramisu_settings*) data->e->data;
	s->selected = MIN(s->count-1, s->selected + 1);
}

static void
dismiss_notifications(BarElementFuncArgs *data) {
	tiramisu_settings *s = (tiramisu_settings*) data->e->data;
	dismiss_message(s, s->selected);
}

