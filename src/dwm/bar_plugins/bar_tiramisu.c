enum { MSG_LOW, MSG_NORMAL, MSG_CRITICAL };
typedef struct {
	FILE *tiramisu_process;
} tiramisu_settings;

static int
bar_notifications(BarElementFuncArgs *data) {
	tiramisu_settings *settings = (tiramisu_settings*) data->e->data;
	if (!settings->tiramisu_process) {
		char proccmd[] = "tiramisu -o '#summary #hints #body'";
		FILE *p = popen(proccmd, "r");
		settings->tiramisu_process = p;
		if (!p) 
			return 0;
	}
	return 0;
}

