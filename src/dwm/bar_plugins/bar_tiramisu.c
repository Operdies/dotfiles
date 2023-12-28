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
read_quote(char *ch, char *dest, int limit)
{
	if (!ch)
		return ch;

	while ((ch) && (*ch) && (isspace(*ch) || (*ch) == '"'))
		ch++;
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
	return ch;
}

static void
pretty_elapsed(char *timestring, int n, struct timespec elapsed)
{
	const int seconds_per_day = 60*60*24;

	int elapsed_seconds = elapsed.tv_sec;
	int i = 0;
	int d = (elapsed_seconds / seconds_per_day);
	int h = (elapsed_seconds / 3600) % 24;
	int m = (elapsed_seconds / 60) % 60;
	int s = elapsed_seconds % 60;

	if (d)
		i += snprintf(timestring+i, n-i-1, "%d %s, ", d, d == 1 ? "day" : "days");
	if (h)
		i += snprintf(timestring+i, n-i-1, "%dh", h);
	if (m)
		i += snprintf(timestring+i, n-i-1, "%dm", m);
	i += snprintf(timestring+i, n-i-1, "%ds", s);
	timestring[i] = 0;
}

static void dismiss_message(tiramisu_settings *s, int i)
{
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

static void
tiramisu_init(BarElementFuncArgs *data)
{
	const int READ = 0;
	const int WRITE = 1;
	int pipes[2] = {0};
	if (pipe(pipes) == -1)
		die("pipe:");
	if (fork() == 0) {
		close(pipes[READ]);
		dup2(pipes[WRITE], STDOUT_FILENO);
		close(pipes[WRITE]);
		// Signal Tiramisu when DWM exits
		prctl(PR_SET_PDEATHSIG, SIGTERM);
		execlp("tiramisu", "tiramisu", "-s", "-o", "\"#hints\" \"#timeout\" \"#summary\" \"#body\"", NULL);
		die("exec:");
	}
	close(pipes[WRITE]);
	if (fcntl(pipes[READ], F_SETFL, O_NONBLOCK) == -1)
		die("fcntl");
	data->e->poll_fd = pipes[READ];
}

static void
bar_notifications(BarElementFuncArgs *data)
{
	if (data->e->poll_fd == 0) {
		data->e->hidden = 1;
		return;
	}

	tiramisu_settings *s = (tiramisu_settings*) data->e->data;
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
		if (data->e->buffer[r-1] != '\n') {
			// flush until newline
			fprintf(stderr, "Notification message exceeded buffer size: ");
			char ch;
			while ((r = read(data->e->poll_fd, &ch, 1)) == 1 && ch != '\n')
				fputc(ch, stderr);
			fputc('\n', stderr);
		}
		notification n = { .when = now };

		char buf[50];
		char *ch = data->e->buffer;
		time_t timeout_ms;

		ch = read_quote(ch, buf, LENGTH(buf));
		if (!sscanf(buf, "urgency=0x%x,", &n.urgency)) {
			fprintf(stderr, "Failed to parse urgency from %s\n", buf);
			return;
		}
		ch = read_quote(ch, buf, LENGTH(buf));
		if (!sscanf(buf, "%ld", &timeout_ms)) {
			fprintf(stderr, "Failed to parse timeout from %s\n", buf);
		}

		if (timeout_ms == -1) {
			n.timeout.tv_sec = MSG_DURATION[n.urgency];
		} else {
			n.timeout.tv_sec = timeout_ms / 1000;
			n.timeout.tv_nsec = (timeout_ms % 1000) * 1e6;
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

	// r == 0 means tiramisu exited
	if (r == 0) {
		fprintf(stderr, "Tiramisu exited.\n");
		close(data->e->poll_fd);
		data->e->poll_fd = 0;
		data->e->scheme = s->schemes[MSG_CRITICAL];
		return;
	}

	data->e->hidden = s->count == 0;
	if (s->count == 0) {
		return;
	}

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

	return;
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

