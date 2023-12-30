#include <X11/XKBlib.h>
#include <X11/extensions/XInput2.h>

#include <stdarg.h>
#include <time.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/select.h>
#include <errno.h>
#include <signal.h>

static char *LED_FILE = "/sys/class/leds/asus::kbd_backlight/brightness";
static char *DISPLAY = ":0";
static int TIMEOUT = 5;
static int LED_STATE = 0;
static int OFF_STATE = 0;
static int ON_STATE = 1;

void writeled(char msg[static 1]);
int readled(void);
void enable_backlight(int force);

void
toggle_backlight(int sig)
{
	ON_STATE = ON_STATE ? 0 : 1;
	enable_backlight(1);
	signal(SIGUSR1, toggle_backlight);
}
void
die(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

	if (fmt[0] && fmt[strlen(fmt)-1] == ':') {
		fputc(' ', stderr);
		perror(NULL);
	} else {
		fputc('\n', stderr);
	}

	exit(1);
}

void 
writeled(char msg[static 1]) {
	FILE *f = fopen(LED_FILE, "w");
	if (!f)
		die("fopen:");
	fwrite(msg, 1, 1, f);
	fclose(f);
}

int
readled() {
	FILE *f = fopen(LED_FILE, "r");
	if (!f)
		die("fopen:");
	int r;
	fscanf(f, "%d", &r);
	return r;
}

void 
disable_backlight() {
	if (LED_STATE) {
		char payload[] = "0";
		payload[0] += OFF_STATE;
		writeled(payload);
		LED_STATE = OFF_STATE;
	}
}

void 
enable_backlight(int force) {
	if (!LED_STATE || force) {
		char payload[] = "0";
		payload[0] += ON_STATE;
		writeled(payload);
		LED_STATE = ON_STATE;
	}
}

void usage(int ret) {
	printf("Usage: \n"\
			"  -t|--timeout  <seconds>\n"
			"  -f|--led-file <filename>\n"
			);
	exit(ret);
}

int 
main(int argc, char * argv[]) {
#define MATCH(short, long) (strcmp("-"#short, argv[i]) == 0 || strcmp("--"#long, argv[i]) == 0)
#define NEXTORDIE if (argc <= i) { printf("Missing positional argument to %s\n", argv[i-1]); usage(1); }
	for (int i = 1; i < argc; i++) {
		if (MATCH(h, help))
			usage(0);
		else if (MATCH(t, timeout)) {
			i++;
			NEXTORDIE;
			if (sscanf(argv[i], "%d", &TIMEOUT) == 0) {
				printf("%s is not an integer.\n", argv[i]);
				usage(1);
			}
		} else if (MATCH(f, led-file)) {
			i++;
			NEXTORDIE;
			LED_FILE = argv[i];
		}
	}

	signal(SIGUSR1, toggle_backlight);

	LED_STATE = readled();
	char *displayname = getenv("DISPLAY");
	if (displayname)
		DISPLAY = displayname;

	Display * display = XOpenDisplay(DISPLAY);
	if (!display)
		die("Cannot open dispaly: %s", displayname);

	Window root = DefaultRootWindow(display);
	int mask_len = XIMaskLen(XI_LASTEVENT);
	XIEventMask m = { 
		.deviceid = XIAllMasterDevices,
		.mask_len = mask_len,
		.mask = calloc(mask_len, sizeof(char)),
	};

	XISetMask(m.mask, XI_RawKeyPress);
	XISelectEvents(display, root, &m, 1);
	XSync(display, false);
	free(m.mask);

	int xfd = ConnectionNumber(display);
	fd_set rd;

	for (;;) {
		FD_ZERO(&rd);
		FD_SET(xfd, &rd);

		select(xfd + 1, &rd, NULL, NULL, &(struct timeval) { .tv_sec = TIMEOUT });

		if (!FD_ISSET(xfd, &rd)) {
			// TIMEOUT reached
			disable_backlight();
		}

		while (XPending(display)) {
			XEvent event;
			XNextEvent(display, &event);
			enable_backlight(0);
		}
	}
}
