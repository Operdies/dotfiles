typedef struct {
	int transmit;
	int receive;
	char ssid[30];
} network_info;

typedef struct {
	char *interface;
} network_settings;

static void bar_network_info(BarElementFuncArgs *data);

static void
bar_network_info(BarElementFuncArgs *data) {
	network_settings *s = (network_settings*)data->e->data;
	int fds[2];
	if (pipe(fds) == -1)
		die("pipe:");

	pid_t pid = fork();

	if (pid == 0) {
		close(fds[0]);
		dup2(fds[1], STDOUT_FILENO);
		close(fds[1]);
		execlp("iw", "iw", "dev", s->interface, "link", NULL);
		die("execlp:");
	}

	close(fds[1]);

	char wifi_off[] = "󰤭";
	char *wifi_levels[] = {
		"󰤟",
		"󰤢",
		"󰤥",
		"󰤨",
	};

	char buf[100];
	FILE *fp = fdopen(fds[0], "r");
	char ssid[30] = {0};
	int signal, rx, tx, found;
	signal = rx = tx = found = 0;

	while (fgets(buf, LENGTH(buf), fp)) {
		char *ch;
		if ((ch = strstr(buf, "SSID: "))) {
			for (int i = 0; i < LENGTH(ssid)-1; i++) {
				char c = ch[LENGTH("SSID:") + i];
				if (c == 0 || c == '\n') {
					ssid[i] = 0;
					break;
				}
				ssid[i] = c;
			}
		} else if ((ch = strstr(buf, "signal:"))) {
			if (!sscanf(ch, "signal: %d dBm", &signal)) {
				fprintf(stderr, "Failed to parse signal from %s\n", ch);
			}
		} else if ((ch = strstr(buf, "RX: "))) {
			if (!sscanf(ch, "RX: %d bytes", &rx))
				fprintf(stderr, "Failed to parse rx from %s\n", ch);
		} else if ((ch = strstr(buf, "TX: "))) {
			if (!sscanf(ch, "TX: %d bytes", &tx))
				fprintf(stderr, "Failed to parse tx from %s\n", ch);
		}
		else {
			continue;
		}
		found++;
		if (found == 4)
			break;
	}
	fclose(fp);
	close(fds[0]);

	int status = 0;
	waitpid(pid, &status, 0);
	int ret = WEXITSTATUS(status);

	if (ret != 0) {
		sprintf(data->e->buffer, "%s iw exited with code %d.", wifi_off, ret);
		return;
	}

	if (found < 4) {
		sprintf(data->e->buffer, "%s", wifi_off);
		return;
	}

	// signal strenght is approxiamtely in the range --150 to -40
	// calculate the scale by badly
	signal += 110;
	signal = CLAMP(signal, 0, 70);
	int level = signal / 18;
	char *icon = wifi_levels[level];

	sprintf(data->e->buffer, "%s %s", icon, ssid);
}

