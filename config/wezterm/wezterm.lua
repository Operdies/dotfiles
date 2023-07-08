local wezterm = require("wezterm")

local pad = 0

return {
	color_scheme = "Gruvbox dark, hard (base16)",
	colors = {
		cursor_fg = wezterm.color.get_default_colors().background,
	},
	font = wezterm.font("Noto Sans Mono"),
	font_size = 10,
	hide_tab_bar_if_only_one_tab = true,

	quick_select_patterns = {
		"['\"`][^'\"`]{2,}['\"`]",
	},
	use_fancy_tab_bar = false,
	window_frame = {
		font_size = 10,
	},
	window_decorations = "NONE",
	window_padding = {
		left = pad,
		right = pad,
		top = pad,
		bottom = pad,
	},
	ssh_domains = {
		{
			name = "win10",
			remote_address = "win10",
			username = "alexw",
		},
	},
	keys = {
		{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
	},
  warn_about_missing_glyphs = false,
}
