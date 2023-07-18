local wezterm = require("wezterm")

return {
	color_scheme = "tokyonight",
	colors = {
		cursor_fg = wezterm.color.get_default_colors().background,
	},
	font = wezterm.font("Noto Sans Mono"),
	font_size = 10,
	hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = true,

	unix_domains = {
		{
			name = "workstation",
		},
	},
	initial_rows = 50,
	initial_cols = 150,
	default_gui_startup_args = { "connect", "unix" },
	quick_select_patterns = {
		"[^ '\"]{3,}",
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}
