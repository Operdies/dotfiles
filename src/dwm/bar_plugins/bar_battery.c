enum { CHARGING = 1, DISCHARGING, FULL };
typedef struct {
	int charge_full;
	int charge_now;
	int current_now;
	int state;
} battery_info;

static int
read_bat(battery_info *bat) {
#define PATH(x) "/sys/class/power_supply/BAT0/" #x
#define read_thing(thing)                          \
	fp = fopen(PATH(thing), "r");                    \
	if (fp) {                                        \
		fgets(pathbuf, 40, fp);                        \
		fclose(fp);                                    \
		bat->thing = atoi(pathbuf);                    \
	} else {                                         \
		return 0;                                      \
	}

	FILE *fp;
	char pathbuf[40];

	read_thing(charge_full);
	read_thing(charge_now);
	read_thing(current_now);

	fp = fopen(PATH(status), "r");
	if (fp) {
		fgets(pathbuf, 40, fp);
		fclose(fp);
		switch (pathbuf[0]) {
			case 'F':
				bat->state = FULL;
				break;
			case 'C':
				bat->state = CHARGING;
				break;
			case 'D': default:
				bat->state = DISCHARGING;
				break;
		}
	}

	return 1;
#undef read_thing
#undef PATH
}

typedef struct {
	int show_details;
	int force_update;
	int no_battery;
	int state; // charging or discharging
} battery_settings;

static void
bar_battery_status(BarElementFuncArgs *data) {
	data->e->hidden = 1;
	battery_settings *settings = (battery_settings*)data->e->data;
	if (settings->no_battery)
		return;
	static int cursor = 0;
	static int chargebuf[10] = {0};
	const char *icon_charging = "";
	const char *icon_full = "󰁹"; //        [0-10)%                                           100%
	const char *icon_charge_levels[11] = { "󱃍", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", icon_full };

	int charge_rate, seconds_remaining, hours, minutes, percentage;
	double left;
	battery_info bat = {0};

	if (!read_bat(&bat)) {
		settings->no_battery = 1;
		return;
	}

	if (settings->state != bat.state) {
		cursor = 0;
		memset(chargebuf, 0, sizeof chargebuf);
		settings->state = bat.state;
	}

	if (bat.state == FULL) {
		sprintf(data->e->buffer, "%s", icon_full);
		data->e->hidden = 0;
		return;
	}

	chargebuf[cursor] = bat.current_now;
	charge_rate = 0;
	{
		double sum = 0;
		int n = 0;
		for (int i = 0; i < LENGTH(chargebuf); i++) {
			int c = chargebuf[i];
			if (c  == 0) break;
			n++;
			sum += c;
		}
		charge_rate = sum / n;
	}
	left = bat.state == DISCHARGING ? bat.charge_now
		: bat.charge_full - bat.charge_now;
	seconds_remaining = (left / charge_rate) * 3600;
	hours = seconds_remaining / 3600;
	minutes = (seconds_remaining % 3600) / 60;
	percentage = ((double)bat.charge_now / bat.charge_full) * 100;
	// Consider the battery 'fully charged' at 99%
	if (percentage >= 99) 
		percentage = 100;

	if (cursor == 0 || settings->force_update) {
		settings->force_update = 0;
		const char *icon = bat.state == CHARGING ? icon_charging : icon_charge_levels[percentage / 10];
		if (settings->show_details && bat.state != FULL) {
			sprintf(data->e->buffer, "%dh%02dm | %d%% | %s", hours, minutes, percentage, icon);
		} else {
			sprintf(data->e->buffer, "%s", icon);
		}
	}
	cursor = (cursor + 1) % LENGTH(chargebuf);
	data->e->hidden = 0;
}

static void
bar_battery_toggle_timer(BarElementFuncArgs *data) {
	battery_settings *settings = (battery_settings*)data->e->data;
	settings->show_details = !settings->show_details;
	settings->force_update = 1;
}

