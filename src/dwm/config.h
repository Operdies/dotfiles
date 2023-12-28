/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static int gap_y                    = 0;
static int gap_x                    = 0;
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int default_tickrate   = 1;
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";
static const char col_babyblue[]    = "#207597";
static const char active_bg[]       = "#5c1a7b";
static const char active_border[]   = "#8c1a9b";
static const char col_gold[]        = "#9D800A";
static const char col_black[]       = "#000000";
static const char col_blue[]        = "#1B5378";
static const char col_red[]         = "#FF0000";
static const char col_green[]       = "#1E854A";
static const char col_white[]       = "#ffffff";
enum {
	SchemeBattery = SchemeSel + 1,
	SchemeClock,
	SchemeSession,
	SchemeCpu,
	SchemeMemory,
	SchemeNetwork,
	SchemeLow,
	SchemeNormal,
	SchemeCritical
};
static const char *colors[][3]      = {
	/*                     fg         bg             border   */
	[SchemeNorm]       = { col_gray3, col_gray1,     col_gray2 },
	[SchemeSel]        = { col_gray4, active_bg,     active_border  },
	[SchemeBattery]    = { col_gray4, col_green,     NULL },
	[SchemeClock]      = { col_gray4, col_gray2,     NULL },
	[SchemeSession]    = { col_gray4, col_black,     NULL },
	[SchemeCpu]        = { col_gray4, col_blue,      NULL },
	[SchemeMemory]     = { col_gray4, col_gold,      NULL },
	[SchemeNetwork]    = { col_gray4, col_babyblue,  NULL },
	[SchemeLow]        = { col_gray4, col_gray1,     NULL },
	[SchemeNormal]     = { col_gray4, col_blue,      NULL },
	[SchemeCritical]   = { col_gray4, col_red,       NULL },
};

static const char dmenufont[]       = "MesloLGS NF:size=11";
static const char *fonts[]          = { "MesloLGS NF:size=11:style=Bold" };

static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
#define DMENU_ARGS "-m", dmenumon, "-i", "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL
static const char *dmenucmd[] = { "dmenu_run", DMENU_ARGS };
static const char *termcmd[]  = { "st", "-e", "tmux", NULL };
static const char *dmenu_nmcli[]  = { "networkmanager_dmenu", "-l", "10", DMENU_ARGS, };

#define CLAMP(x, lower, upper) ((x) < (lower) ? (lower) : (x) > (upper) ? (upper) : (x))
/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) ((Arg){ .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } })
#define QUIETCMD(cmd) ((Arg) { .v = (const char*[]){ "/bin/sh", "-c", cmd " > /dev/null 2>&1", NULL }})

#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "bar_plugins/bar_battery.c"
#include "bar_plugins/bar_mem.c"
#include "bar_plugins/bar_clock.c"
#include "bar_plugins/bar_cpu.c"
#include "bar_plugins/bar_tiramisu.c"
#include "bar_plugins/bar_tail.c"
#include "bar_plugins/bar_network.c"

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
#define MODKEY Mod4Mask
#define MetaMask Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|MetaMask,              KEY,      toggletag,      {.ui = 1 << TAG} }

static void
setgap(const Arg *arg)
{
	if (!arg) return;
	gap_y = MAX(gap_y + arg->i, 0);
	gap_x = MAX(gap_x + arg->i, 0);
	arrange(selmon);
}

static void
bar_session_info_init(BarElementFuncArgs *data)
{
	char *display = getenv("DISPLAY");
	char *vtnr = getenv("XDG_VTNR");
	sprintf(data->e->buffer, "VT%s X%s", vtnr, display);
}

/* commands */
BarElement BarElements[] =
{
	{
		.data = &(network_settings) { .interface = "wlan0" },
		.interval = default_tickrate,
		.scheme = SchemeNetwork,
		.click = { [LeftClick] = bar_network_list },
		.update = bar_network_info,
	},
	{
		.interval = 5,
		.scheme = SchemeMemory,
		.update = bar_mem_usage,
	},
	{
		.click = { [LeftClick] = bar_cpu_braille },
		.data = &(cpu_settings) { .show_braille = 0 },
		.interval = default_tickrate,
		.scheme = SchemeCpu,
		.update = bar_cpu_usage,
	},
	{
		.click = { [LeftClick] = bar_battery_toggle_timer },
		.data = &(battery_settings) { .show_time = 1 },
		.interval = 1,
		.scheme = SchemeBattery,
		.update = bar_battery_status,
	},
	{
		.click = { [LeftClick] = bar_clock_click, [RightClick] = open_calendar },
		.data = &(clock_settings) { .show_seconds = 0 },
		.interval = 1,
		.scheme = SchemeClock,
		.update = bar_clock,
	},
	{
		.click = {
			[LeftClick] = bar_toggle_shown,
			[RightClick] = dismiss_notifications,
			[ScrollDown] = next_notification,
			[ScrollLeft] = bar_scroll_left,
			[ScrollRight] = bar_scroll_right,
			[ScrollUp] = prev_notification,
		},
		.data = &(tiramisu_settings) {
			.schemes = { [MSG_LOW] = SchemeLow, [MSG_NORMAL] = SchemeNormal, [MSG_CRITICAL] = SchemeCritical  },
			.max_length = 16,
			.icons = (char*[]) {
				"wifi", "󰤩",
				"rhkd", "X",
				NULL,
			},
		},
		.init = tiramisu_init,
		.interval = 1,
		.update = bar_notifications,
	},
	{
		.init = bar_session_info_init,
		.interval = -1,
		.scheme = SchemeSession,
	},
};


static const Key keys[] =
{
	/* modifier                     key        function        argument */
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_w,      spawn,          {.v = dmenu_nmcli } },
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
static const Button buttons[] =
{
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              LeftClick,      setlayout,      {0} },
	{ ClkLtSymbol,          0,              RightClick,     setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         LeftClick,      movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         RightClick,     resizemouse,    {0} },
	{ ClkTagBar,            0,              LeftClick,      view,           {0} },
	{ ClkTagBar,            0,              RightClick,     toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         LeftClick,      tag,            {0} },
	{ ClkTagBar,            MODKEY,         RightClick,     toggletag,      {0} },
};

