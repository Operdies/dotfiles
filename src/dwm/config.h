#include "catppuccin_mocha_palette.h"
/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static int gap_y                    = 0;
static int gap_x                    = 0;
static int barelembars              = ~0;
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int default_tickrate   = 1;
static const int mouse_warp         = 1;
enum {
	SchemeBattery = SchemeSel + 1,
	SchemeClock,
	SchemeCpu,
	SchemeMemory,
	SchemeNetwork,
	SchemeLow,
	SchemeNormal,
	SchemeCritical
};
static const char *colors[][3]      = {
	/*                     fg             bg             border   */
	[SchemeNorm]       = { col_Text,      col_Crust,     col_Overlay0,        },
	[SchemeSel]        = { col_Mauve,     col_Base,      col_Mauve },
	[SchemeBattery]    = { col_Blue,      col_Base,      NULL },
	[SchemeClock]      = { col_Mauve,     col_Base,      NULL },
	[SchemeCpu]        = { col_Sapphire,  col_Base,      NULL },
	[SchemeMemory]     = { col_Peach,     col_Base,      NULL },
	[SchemeNetwork]    = { col_Red,       col_Base,      NULL },
	[SchemeLow]        = { col_Rosewater, col_Base,      NULL },
	[SchemeNormal]     = { col_Pink,      col_Base,      NULL },
	[SchemeCritical]   = { col_Surface0,  col_Red,       NULL },
};

static const char dmenufont[]       = "MesloLGS NF:size=11";
static const char *fonts[]          = { "MesloLGS NF:size=11:style=Bold" };
static const char bar_plugin_separator[] = "│";

static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
#define DMENU_ARGS "-m", dmenumon, "-i", "-fn", dmenufont, "-nb", col_Base, "-nf", col_Text, "-sb", col_Mauve, "-sf", col_Surface0, NULL
static const char *dmenucmd[] = { "dmenu_run", DMENU_ARGS };
static const char *termcmd[]  = { "alacritty", "-e", "tmux", NULL };
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

#ifdef LAPTOP
#include "bar_plugins/bar_keyboard.c"
#endif // LAPTOP

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
// static const char *tags[] = { "🯱", 	"🯲", 	"🯳", 	"🯴", 	"🯵", 	"🯶", 	"🯷", 	"🯸", 	"🯹" };
static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class             instance    title       tags mask     isfloating   monitor    icon*/
	{ "firefox",         NULL,       NULL,       0,            0,           -1,        .icon="",   },
	{ "Pavucontrol",     NULL,       NULL,       0,            1,           -1,        .icon="",   },
	{ "discord",         NULL,       NULL,       0,            0,           -1,        .icon="ﭮ",   },
	{ "Zathura",         NULL,       NULL,       0,            0,           -1,        .icon="󰈦",   },
	{ "nvim",            "nvim",     "nvim",     0,            0,           -1,        .icon="",   },
	{ "vim",             "vim",      "vim",      0,            0,           -1,        .icon="",   },
	{ "tmux",            NULL,       "tmux",     0,            0,           -1,        .icon="",   },
	{ "st",              NULL,       NULL,       0,            0,           -1,        .icon="",   },
	{ "thunar",          NULL,       NULL,       0,            0,           -1,        .icon="",   },
	{ "steam_app_6910",  NULL,       NULL,       0,            1,           -1,        .icon="",   },
	{ "steam_proton",    NULL,       NULL,       0,            1,           -1,        .icon="",   },
};

/* layout(s) */
static const float mfact     = 0.65; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 2;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

enum { TILEWIDE, FLOATING, MONOCLE };
static const Layout layouts[] = {
	/* layout       symbol     arrange function */
	[TILEWIDE] = { "[]=",      tilewide },/* first entry is default */
	[FLOATING] = { "><>",      NULL },    /* no layout function means floating behavior */
	[MONOCLE]  = { "[M]",      monocle },
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
bar_session_info(BarElementFuncArgs *data)
{
	static char *display = NULL;
	static char *vtnr = NULL;
	if (!display)
		display = getenv("DISPLAY");
	if (!display)
		display = "None";
	if (!vtnr) 
		vtnr = getenv("XDG_VTNR");
	if (!vtnr)
		vtnr = "None";
	if (data->m && mons && mons->next) // there is more than one monitor
		sprintf(data->e->buffer, "M%d VT%s X%s", data->m->num, vtnr, display);
	else
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
		.click = { 
				[LeftClick] = bar_battery_toggle_timer,
				[RightClick] = bar_battery_toggle_percent,
		},
		.data = &(battery_settings) { .details = BAT_SHOW_ICON | BAT_SHOW_PERCENT | BAT_SHOW_TIME },
		.interval = default_tickrate,
		.scheme = SchemeBattery,
		.update = bar_battery_status,
	},
	{
		.click = { [LeftClick] = bar_clock_click, [RightClick] = open_calendar },
		.data = &(clock_settings) { .show_seconds = 0 },
		.interval = default_tickrate,
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
		.interval = default_tickrate,
		.update = bar_notifications,
	},
};

static int quake_tag = 7;

void
quake(const Arg *arg)
{
	if (selmon) {	
		int tag = 1 << quake_tag;
		int tag_selected = (selmon->seltags & tag) > 0;
		Client *c = NULL;
		toggleview(&(Arg) { .ui = tag });
		if (!tag_selected) {
			for (c = selmon->stack; c && !ISVISIBLEONTAG(c, tag); c = c->next) 
			;
			if (c)
				focus(c);
		}
	}
}

static void swipe(const Arg *arg) {
	int i;
	unsigned int occ = 0;
	Monitor *m = selmon;
	Client *c;

	for (c = m->clients; c; c = c->next)
		occ |= c->tags;
	for (i = 0; i < LENGTH(tags) && !(m->tagset[m->seltags] & 1 << i); i++);

	i += arg->i;
	for (; i >= 0 && i < LENGTH(tags); i += arg->i) {
		if (occ & 1 << i) {
			view(&(Arg){ .ui = 1 << i});
			break;
		}
	}
}

static const Key keys[] =
{
	/* modifier                     key        function                 argument */
	{ 0,                            XF86XK_AudioPrev,   swipe,                   {.i = -1}},
	{ 0,                            XF86XK_AudioNext,   swipe,                   {.i = 1}},
	{ MODKEY|ShiftMask,             XK_Return,          spawn,                   {.v = termcmd } },
	{ MODKEY,                       XK_p,               spawn,                   {.v = dmenucmd } },
	{ MODKEY,                       XK_d,               spawn,                   {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_w,               spawn,                   {.v = dmenu_nmcli } },
	{ MODKEY|ShiftMask,             XK_b,               togglebar,               {0} },
	{ MODKEY|ControlMask|ShiftMask, XK_b,               togglebarelems,          {0} },
	{ MODKEY,                       XK_j,               focusstack,              {.i = +1 } },
	{ MODKEY,                       XK_k,               focusstack,              {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_j,               pushdown,                {0} },
	{ MODKEY|ShiftMask,             XK_k,               pushup,                  {0} },
	{ MODKEY|ShiftMask,             XK_i,               setgap,                  {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_o,               setgap,                  {.i = +1 } },
	{ MODKEY,                       XK_i,               incnmaster,              {.i = +1 } },
	{ MODKEY,                       XK_o,               incnmaster,              {.i = -1 } },
	{ MODKEY,                       XK_h,               setmfact,                {.f = -0.05} },
	{ MODKEY,                       XK_l,               setmfact,                {.f = +0.05} },
	{ MODKEY|ControlMask|ShiftMask, XK_v,               togglebar,               {0} },
	{ MODKEY|ControlMask|ShiftMask, XK_v,               splitmon,                {0} },
	{ MODKEY,                       XK_g,               zoom,                    {0} },
	{ MODKEY,                       XK_Tab,             view,                    {0} },
	{ MODKEY,                       XK_q,               killclient,              {0} },
	{ MODKEY,                       XK_t,               setlayout,               {.v = &layouts[TILEWIDE]} },
	{ MODKEY,                       XK_m,               setlayout,               {.v = &layouts[MONOCLE]} },
	{ MODKEY,                       XK_space,           setlayout,               {0} },
	{ MODKEY|ShiftMask,             XK_space,           togglefloating,          {0} },
	{ MODKEY,                       XK_0,               view,                    {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,               toggleview,              {.ui = ~0 } },
	{ MODKEY,                       XK_period,          focusmon,                {.i = -1 } },
	{ MODKEY,                       XK_comma,           focusmon,                {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_period,          tagmon,                  {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_comma,           tagmon,                  {.i = +1 } },
	TAGKEYS(                        XK_1,                                        0),
	TAGKEYS(                        XK_2,                                        1),
	TAGKEYS(                        XK_3,                                        2),
	TAGKEYS(                        XK_4,                                        3),
	TAGKEYS(                        XK_5,                                        4),
	TAGKEYS(                        XK_6,                                        5),
	TAGKEYS(                        XK_7,                                        6),
	TAGKEYS(                        XK_8,                                        7),
	TAGKEYS(                        XK_9,                                        8),
	{ MODKEY|ShiftMask,             XK_q,               quit,                    {0} },
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

