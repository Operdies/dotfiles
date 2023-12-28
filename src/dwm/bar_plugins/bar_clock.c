typedef struct {
	int show_seconds;
} clock_settings;

static void
bar_clock(BarElementFuncArgs *data)
{
	clock_settings *s = (clock_settings*)data->e->data;
	time_t t;
	time(&t);
	struct tm *tm = localtime(&t);
	if (s && s->show_seconds)
		strftime(data->e->buffer, 100, "%a %b %d %H:%M:%S", tm);
	else
		strftime(data->e->buffer, 100, "%a %b %d %H:%M", tm);
}

static void
bar_clock_click(BarElementFuncArgs *data) {
	clock_settings *s = (clock_settings*)data->e->data;
	s->show_seconds = !s->show_seconds;
}

static void
open_calendar(BarElementFuncArgs *data) {
	spawn(& QUIETCMD("gsimplecal"));
}

