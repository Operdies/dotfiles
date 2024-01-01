typedef struct {
	int transmit;
	int receive;
	char ssid[30];
} network_info;

typedef struct {
	char *interface;
	int iw_missing;
} network_settings;

static void bar_network_info(BarElementFuncArgs *data);
static void bar_network_list(BarElementFuncArgs *data);

static void
bar_network_info(BarElementFuncArgs *data)
{
	char wifi_off[] = "󰤭";
	char *wifi_levels[] = {
		"󰤟",
		"󰤢",
		"󰤥",
		"󰤨",
	};
	char ethernet[] = "󰈀";

	int fds[2];
	char buf[100];
	char ssid[30] = {0};
	int signal, rx, tx, found;

	network_settings *s = (network_settings*)data->e->data;
	if (s->iw_missing) {
		return;
	}

	if (pipe(fds) == -1)
		die("pipe:");

	pid_t pid = fork();

	if (pid == 0) {
		close(fds[0]);
		dup2(fds[1], STDOUT_FILENO);
		close(fds[1]);
		execlp("iw", "iw", "dev", s->interface, "link", NULL);
		putchar(0);
		exit(0);
	}

	close(fds[1]);
	signal = rx = tx = found = 0;

	FILE *fp = fdopen(fds[0], "r");
	int did_read = 0;
	while (fgets(buf, LENGTH(buf), fp)) {
		did_read = 1;
		if (buf[0] == 0)
			break;
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

	if (buf[0] == 0 || did_read == 0) {
		// assume ethernet
		s->iw_missing = 1;
		data->e->hidden = 1;
		strcpy(data->e->buffer, ethernet);
		return;
	}

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

static void
bar_network_list(BarElementFuncArgs *data)
{
	spawn(&(Arg) { .v = dmenu_nmcli });
}
