#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/prctl.h>

typedef struct {
	char summary[30];
	char message[CHARBUFSIZE-30-2];
	unsigned int urgency;
	time_t when;
} notification;

enum { MSG_LOW, MSG_NORMAL, MSG_CRITICAL };
typedef struct {
	int schemes[MSG_CRITICAL+1];
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
pretty_elapsed(char *timestring, int n, time_t when) {
	const int seconds_per_day = 60*60*24;

	int elapsed = time(NULL) - when;
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
			prctl(PR_SET_PDEATHSIG, SIGHUP);
			execlp("tiramisu", "tiramisu", "-s", "-o", "\"#hints\" \"#summary\" \"#body\"", NULL);
			die("exec:");
		}
	}

	int r;

	if ((r = read(data->e->poll_fd, data->e->buffer, LENGTH(data->e->buffer))) > 0) {
		notification n = { .when = time(NULL) };
		char urgencybuf[100];
		char *ch = data->e->buffer;
		ch = read_quote(ch, urgencybuf, LENGTH(urgencybuf));
		ch = read_quote(ch, n.summary, LENGTH(n.summary));
		read_quote(ch, n.message, LENGTH(n.message));

		if (!sscanf(urgencybuf, "urgency=0x%x,", &n.urgency)) {
			fprintf(stderr, "Failed to parse urgency from %s\n", urgencybuf);
			return 0;
		}

		for (char **pair = s->icons; *pair; pair += 2) {
			char *title = pair[0];
			char *icon = pair[1];
			if (title && icon && strcmp(title, n.summary) == 0) {
				strncpy(n.summary, icon, LENGTH(n.summary));
				break;
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


	// reset poll_fd so tiramisu will be restarted
	if (r == 0) {
		fprintf(stderr, "Tiramisu exited. Will restart later.\n");
		close(data->e->poll_fd);
		data->e->poll_fd = 0;
	}

	if (s->count == 0)
		return 0;

	int limit = CHARBUFSIZE - 1;
	if (s->max_length)
		limit = MIN(limit, s->max_length);

	notification *n = &s->history[s->selected];
	data->e->scheme = s->schemes[n->urgency];
	char timestring[100];
	pretty_elapsed(timestring, LENGTH(timestring), n->when);
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
