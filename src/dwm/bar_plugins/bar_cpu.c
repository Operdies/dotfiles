typedef struct {
	ulong user;
	ulong nice;
	ulong system;
	ulong idle;
	ulong iowait;
	ulong irq;
	ulong softirq;
} proc_stat;

typedef struct {
	int show_braille;
} cpu_settings;

static int
bar_cpu_usage(BarElementFuncArgs *data) {
#define NPROC 8
#define SCAN_LINE(f, n) fscanf(f, JIFFLE_FMT(n), JIFFLE_ARGS(n));
#define WORK(j) ((j)->user + (j)->nice + (j)->system)
#define IDLE(j) ((j)->idle + (j)->iowait + (j)->irq + (j)->softirq)
#define TOTAL(j) (WORK(j) + IDLE(j))
#define UTILIZATION(p, c) ((double)(WORK(c) - WORK(p)) / (TOTAL(c) - TOTAL(p)) * 100)

	cpu_settings *s = (cpu_settings*)data->e->data;
	static proc_stat prev_jiffles[NPROC+1] = {0};
	proc_stat jiffles[NPROC+1] = {0};

	const char *levels[] = { "⡀", "⣀", "⣄", "⣤", "⣦", "⣶", "⣷", "⣿" };

	FILE *f = fopen("/proc/stat", "r");
	if (!f) return 0;

	for (int i = 0; i < NPROC+1; i++) {
		proc_stat *jiffle = jiffles + i;
		char sink[10];
		fscanf(f, "%s %lu %lu %lu %lu %lu %lu %lu", sink, &jiffle->user, &jiffle->nice, &jiffle->system, &jiffle->idle, &jiffle->iowait, &jiffle->irq, &jiffle->softirq);
		// skip rest of line
		for (char ch = fgetc(f); ch != EOF && ch != '\n'; ch = fgetc(f));
	}
	fclose(f);

	int n = 0;
	n += snprintf(data->e->buffer + n, CHARBUFSIZE - n - 1, " ");

	if (s && s->show_braille)
		for (int i = 1; i < NPROC+1; i++) {
			double utilization = UTILIZATION(prev_jiffles+i, jiffles+i);
			double increment = 100.0 / LENGTH(levels);
			int index = utilization / increment;
			index = CLAMP(index, 0, LENGTH(levels)-1);
			n += snprintf(data->e->buffer + n, CHARBUFSIZE - n - 1, "%s", levels[index]);
		}
	n += snprintf(data->e->buffer + n, CHARBUFSIZE - n - 1, "%d%%", (int)UTILIZATION(prev_jiffles, jiffles));

	memcpy(prev_jiffles, jiffles, sizeof(jiffles));

	return 1;
#undef NPROC
#undef SCAN_LINE
#undef WORK
#undef IDLE
#undef TOTAL
#undef UTILIZATION
}

static void
bar_cpu_braille(BarElementFuncArgs *data) {
	cpu_settings *s = (cpu_settings*)data->e->data;
	s->show_braille = !s->show_braille;
}

