#include <ctype.h>

typedef struct {
	const char *path;
	unsigned int max_length;
	unsigned int prev_length;
	char backbuf[CHARBUFSIZE];
} tail_settings;

static int
tail_file (BarElementFuncArgs *data) {
	FILE *f;
	tail_settings *s;
	s = (tail_settings*)data->e->data;

	if (s == NULL || s->path == NULL)
		return 0;
	f = fopen(s->path, "r");
	if (!f)
		return 0;

	char *buf = data->e->buffer;

	int limit = CHARBUFSIZE - 1;
	if (s->max_length)
		limit = MIN(limit, s->max_length);

	fseek(f, -limit, SEEK_END);
	int pos = ftell(f);
	int read = fread(buf, 1, limit, f);
	fclose(f);

	buf[read] = 0;
	int n;
	for (n = read - 1; n > 0 && isspace(buf[n]); n--)
		buf[n] = 0;
	n++;
	int lastline;
	for (lastline = n - 1; lastline > 0 && buf[lastline] != '\n'; lastline--);
	if (pos > 0 && lastline == 0) {
		// message was truncated
		buf[0] = buf[1] = buf[2] = '.';
	}

	if (buf[lastline] == '\n')
		lastline++;

	int count = n - lastline;
	memmove(buf, buf+lastline, count);
	buf[count] = 0;

	return 1;
}

static void
tail_scroll_right (BarElementFuncArgs *data) {
	tail_settings *s = (tail_settings*)data->e->data;
	if (s->max_length == 0)
		return;
	s->max_length = CLAMP(s->max_length+1, 5, CHARBUFSIZE-1);
}
static void
tail_scroll_left (BarElementFuncArgs *data) {
	tail_settings *s = (tail_settings*)data->e->data;
	if (s->max_length == 0)
		return;
	s->max_length = CLAMP(s->max_length - 1, 5, CHARBUFSIZE-1);
}

static void
tail_toggle_shown(BarElementFuncArgs *data) {
	tail_settings *s;
	s = (tail_settings*)data->e->data;
	int tmp = s->prev_length;
	s->prev_length = s->max_length;
	s->max_length = tmp;
}
