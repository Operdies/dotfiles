enum { CHARGING = 1, DISCHARGING };
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
	if (fp) { 																			 \
		fgets(pathbuf, 40, fp);                        \
		fclose(fp);                                    \
		bat->thing = atoi(pathbuf);										 \
	} else { 																				 \
	  return 0;																			 \
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
		bat->state = pathbuf[0] == 'C' ? CHARGING : DISCHARGING;
	}

  return 1;
#undef read_thing
#undef PATH
}

typedef struct {
	int show_time;
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
	if (cursor == 0 || settings->force_update) {
		settings->force_update = 0;
		int n = snprintf(data->e->buffer, sizeof data->e->buffer - 1, "%d%% %s", percentage,
					 bat.state == CHARGING ? "" : "");
		if (settings->show_time)
			sprintf(data->e->buffer + n, " %d:%02d", hours, minutes);
	}
	cursor = (cursor + 1) % LENGTH(chargebuf);
	data->e->hidden = 0;
}

static void
bar_battery_toggle_timer(BarElementFuncArgs *data) {
	battery_settings *settings = (battery_settings*)data->e->data;
	settings->show_time = !settings->show_time;
	settings->force_update = 1;
}

