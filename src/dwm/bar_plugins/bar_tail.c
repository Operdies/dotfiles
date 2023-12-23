typedef struct {
	const char *path;
	size_t prev_end;
	unsigned int max_length;
	char backbuf[CHARBUFSIZE];
} tail_settings;

static int
tail_file (BarElementFuncArgs *data) {
	FILE *f;
	tail_settings *s;
	s = (tail_settings*)data->e->data;

	if (s && s->max_length > 0) {
		memcpy(data->e->buffer, s->backbuf, s->max_length);
		data->e->buffer[s->max_length] = 0;
	}

	if (s && s->path) {
		f = fopen(s->path, "r");
		if (f) {
			fseek(f, 0, SEEK_END);
			size_t loc = ftell(f);
			if (loc == s->prev_end)
				return 1;
			s->prev_end = loc;
			loc -= 2; /* skip back past EOF and last newline */
			while (loc > 0) {
				fseek(f, loc, SEEK_SET);
				loc--;
				char ch = fgetc(f);
				if (ch == '\n' || loc == 0) {
					int r = fread(s->backbuf, 1, CHARBUFSIZE-2, f);

					int i = r-1;
					while (s->backbuf[i] == '\n')
						s->backbuf[i] = 0;

					memcpy(data->e->buffer, s->backbuf, r);
					for (int i = 0; i < r; i++) {
						if (data->e->buffer[i] == '\n')
							data->e->buffer[i] = 0;
					}
					if (s->max_length && s->max_length < r)
						data->e->buffer[s->max_length] = 0;
					data->e->buffer[r] = 0;
					fclose(f);
					return 1;
				}
			}
			fclose(f);
		}
	}
	return 0;
}

static void
tail_scroll_right (BarElementFuncArgs *data) {
	tail_settings *s;
	s = (tail_settings*)data->e->data;
	s->max_length = CLAMP(s->max_length+1, 0, strlen(s->backbuf));
}
static void
tail_scroll_left (BarElementFuncArgs *data) {
	tail_settings *s;
	s = (tail_settings*)data->e->data;
	s->max_length = CLAMP(s->max_length - 1, 5, strlen(s->backbuf));
}
