typedef struct {
	int attached;
} keyboard_settings;

static int
keyboard_attached(void){
	FILE *f = popen("xinput", "r");
	char *line = NULL;
	size_t len;
	ssize_t read;
	int attached = 0;
	while ((read = getline(&line, &len, f)) != -1){
		if (strstr(line, "id=13")){
			attached = strstr(line, "[floating slave]") ? 0 : 1;
			break;
		}
	}
	pclose(f);
	free(line);
	return attached;
}

static void
bar_keyboard(BarElementFuncArgs *data)
{
	keyboard_settings *s = (keyboard_settings*)data->e->data;
	s->attached = keyboard_attached();
	const char *status[] = {
		[0] = "󰌐",
		[1] = "󰌌",
	};
	snprintf(data->e->buffer, 100, "%s", status[s->attached]);
}

static void
bar_keyboard_click(BarElementFuncArgs *data){
	keyboard_settings *s = (keyboard_settings*)data->e->data;
	if (keyboard_attached()){
		spawn(& QUIETCMD("xinput float 13"));
		s->attached = 0;
	} else {
		spawn(& QUIETCMD("xinput reattach 13 3"));
		s->attached = 1;
	}
}

