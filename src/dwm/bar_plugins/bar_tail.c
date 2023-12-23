typedef struct {
	const char *path;
} tail_settings;

static int
tail_file (BarElementFuncArgs *data) {
	FILE *f;
	tail_settings *s;

	s = (tail_settings*)data->e->data;
	if (s && s->path) {
		f = fopen(s->path, "r");
		if (f) {
			fclose(f);
		}
	}
	return 0;
}

