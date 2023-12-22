/* See LICENSE file for copyright and license details. */

#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

/* appearance */
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int bar_tick_rate      = 1;
static int gap_y                    = 0;
static int gap_x                    = 0;
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";
static const char active_bg[]       = "#5c1a7b";
static const char active_border[]   = "#8c1a9b";
static const char col_gold[]        = "#9D800A";
static const char col_black[]       = "#000000";
static const char col_blue[]        = "#1B5378";
static const char col_green[]       = "#1E854A";
static const char col_white[]       = "#ffffff";
enum { SchemeBattery = SchemeSel + 1, SchemeClock, SchemeCpu, SchemeMemory };
static const char *colors[][3]      = {
	/*                     fg         bg         border   */
	[SchemeNorm]       = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]        = { col_gray4, active_bg, active_border  },
	[SchemeBattery]    = { col_gray4, col_green, NULL },
	[SchemeClock]      = { col_gray4, col_gray2, NULL },
	[SchemeCpu]        = { col_gray4, col_blue,  NULL },
	[SchemeMemory]     = { col_gray4, col_gold,  NULL },
};

static const char dmenufont[]       = "MesloLGS NF:size=11";
static const char *fonts[]          = { "MesloLGS NF:size=11:style=Bold" };

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class          instance    title       tags mask     isfloating   monitor    icon*/
	{ "firefox",      NULL,       NULL,       1 << 2,       0,           -1,        .icon="",   },
	{ "Pavucontrol",  NULL,       NULL,       1 << 3,       0,           -1,        .icon="",   },
	{ "discord",      NULL,       NULL,       1 << 8,       0,           -1,        .icon="ﭮ",   },
	{ "Zathura",      NULL,       NULL,       1 << 3,       0,           -1,        .icon="󰈦",   },
	{ "nvim",         "nvim",     "nvim",     0,            0,           -1,        .icon="",   },
	{ "vim",          "vim",      "vim",      0,            0,           -1,        .icon="",   },
	{ "tmux",         NULL,       "tmux",     0,            0,           -1,        .icon="",   },
	{ "st",           NULL,       NULL,       0,            0,           -1,        .icon="",   },
	{ "thunar",       NULL,       NULL,       0,            0,           -1,        .icon="",   },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "[][]=",    tilewide },
};

/* key definitions */
#define CLAMP(x, lower, upper) ((x) < (lower) ? (lower) : (x) > (upper) ? (upper) : (x))
#define MODKEY Mod4Mask
#define MetaMask Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|MetaMask,              KEY,      toggletag,      {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
	int n = 0;

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *termcmd[]  = { "st", "-e", "tmux", NULL };

enum { CHARGING, DISCHARGING };
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
} battery_settings;

static int
bar_battery_status(const BarElementFuncArgs *data) {
	battery_settings *settings = (battery_settings*)data->e->data;
	static int cursor = 0;
	static int chargebuf[10] = {0};

	int charge_rate, seconds_remaining, hours, minutes, percentage;
	double left;
	battery_info bat = {0};

	if (!read_bat(&bat)) {
		return 0;
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
	return 1;
}

static void
bar_battery_toggle_timer(const BarElementFuncArgs *data) {
	battery_settings *settings = (battery_settings*)data->e->data;
	settings->show_time = !settings->show_time;
	settings->force_update = 1;
}

typedef struct {
	int show_seconds;
} clock_settings;

static int
bar_clock(const BarElementFuncArgs *data) {
	clock_settings *s = (clock_settings*)data->e->data;
	time_t t;
	time(&t);
	struct tm *tm;
	tm = localtime(&t);
	if (s && s->show_seconds)
		strftime(data->e->buffer, 100, "%a %b %d %H:%M:%S", tm);
	else
		strftime(data->e->buffer, 100, "%a %b %d %H:%M", tm);
	return 1;
}

static void
bar_clock_click(const BarElementFuncArgs *data) {
	clock_settings *s = (clock_settings*)data->e->data;
	s->show_seconds = !s->show_seconds;
}

typedef unsigned long long u64;

static int
bar_mem_usage(const BarElementFuncArgs *data) {
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

typedef struct {
	u64 user;
	u64 nice;
	u64 system;
	u64 idle;
	u64 iowait;
	u64 irq;
	u64 softirq;
} proc_stat;

typedef struct {
	int show_braille;
} cpu_settings;

static int
bar_cpu_usage(const BarElementFuncArgs *data) {
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
		fscanf(f, "%s %llu %llu %llu %llu %llu %llu %llu", sink, &jiffle->user, &jiffle->nice, &jiffle->system, &jiffle->idle, &jiffle->iowait, &jiffle->irq, &jiffle->softirq);
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
bar_cpu_braille(const BarElementFuncArgs *data) {
	cpu_settings *s = (cpu_settings*)data->e->data;
	s->show_braille = !s->show_braille;
}

static void
open_calendar(const BarElementFuncArgs *data) {
	const char *args[] = { "gsimplecal", NULL };
	spawn(&(Arg) { .v = args });
}

static void
setgap(const Arg *arg) {
	if (!arg) return;
	gap_y = MAX(gap_y + arg->i, 0);
	gap_x = MAX(gap_x + arg->i, 0);
	arrange(selmon);
}

static BarElement BarElements[]    = {
	{ 
		.interval = 1,
		.scheme = SchemeMemory,  
		.update = bar_mem_usage, 			
	},
	{ 
		.click = { [Button1] = bar_cpu_braille }, 
		.data = &(cpu_settings) { .show_braille = 1 },
		.interval = 1, 
		.scheme = SchemeCpu,     
		.update = bar_cpu_usage, 			
	},
	{ 
		.click = { [Button1] = bar_battery_toggle_timer },
		.data = &(battery_settings) { .show_time = 1 },
		.interval = 1, 
		.scheme = SchemeBattery, 
		.update = bar_battery_status, 
	},
	{ 
		.click = { [Button1] = bar_clock_click, [Button3] = open_calendar },
		.data = &(clock_settings) { .show_seconds = 0 },
		.interval = 1, 
		.scheme = SchemeClock,   
		.update = bar_clock,          
	},
};

static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_j,      pushdown,       {0} },
	{ MODKEY|ShiftMask,             XK_k,      pushup,         {0} },
	{ MODKEY|ShiftMask,             XK_i,      setgap,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_o,      setgap,         {.i = +1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_o,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_equal,  setmfact,       {.f = +1.5} },
	{ MODKEY,                       XK_g,      zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setnmaster,     {.i = 1 } },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_w,      setnmaster,     {.i = 2 } },
	{ MODKEY,                       XK_w,      setlayout,      {.v = &layouts[3]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      toggleview,     {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0),
	TAGKEYS(                        XK_2,                      1),
	TAGKEYS(                        XK_3,                      2),
	TAGKEYS(                        XK_4,                      3),
	TAGKEYS(                        XK_5,                      4),
	TAGKEYS(                        XK_6,                      5),
	TAGKEYS(                        XK_7,                      6),
	TAGKEYS(                        XK_8,                      7),
	TAGKEYS(                        XK_9,                      8),
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

