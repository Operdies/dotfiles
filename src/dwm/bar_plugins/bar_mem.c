static int
bar_mem_usage(BarElementFuncArgs *data) {
	const char *memicon = "";
	unsigned long memtotal;
	unsigned long active;
	char *memtotal_s, *active_s;

	FILE *f = fopen("/proc/meminfo", "r");
	if (!f) return 0;
	int r = fread(data->e->buffer, 1, CHARBUFSIZE, f);
	data->e->buffer[r] = 0;
	fclose(f);

	memtotal_s = strstr(data->e->buffer, "MemTotal:");
	if (!memtotal_s)
		return 0;
	active_s = strstr(data->e->buffer, "Active:");
	if (!active_s)
		return 0;

	if (!sscanf(memtotal_s, "MemTotal: %lu kB", &memtotal))
		return 0;
	if (!sscanf(active_s, "Active: %lu kB", &active))
		return 0;

	double gbtotal = (double)memtotal / (1 << 20);
	double gbused = (double)active / (1 << 20);
	double pct = (gbused / gbtotal) * 100;

	if (gbused >= 1.0) {
		sprintf(data->e->buffer, "%s %.1lf Gi / %.1lf Gi %d%%", memicon, gbused, gbtotal, (int)pct);
	} else {
		gbused *= (1 << 10);
		sprintf(data->e->buffer, "%s %.0lf Mi / %.1lf Gi %d%%", memicon, gbused, gbtotal, (int)pct);
	}

	return 1;
}

