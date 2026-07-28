vv.options.theme = require('velvet.themes').catppuccin.mocha

-- It's nice to have some extra nuances in addition to the basic palette without having to specify rgb codes everywhere.
-- Many velvet color APIs accept additional named colors by adding them to the theme.
local catppuccin_mocha = {
  -- base ansi theme
  background = "#1e1e2e",
  black = "#45475a",
  blue = "#89b4fa",
  bright_black = "#585b70",
  bright_blue = "#89b4fa",
  bright_cyan = "#94e2d5",
  bright_green = "#a6e3a1",
  bright_magenta = "#f5c2e7",
  bright_red = "#f38ba8",
  bright_white = "#a6adc8",
  bright_yellow = "#f9e2af",
  cursor_background = "#f5e0dc",
  cursor_foreground = "#1e1e2e",
  cyan = "#94e2d5",
  foreground = "#cdd6f4",
  green = "#a6e3a1",
  magenta = "#f5c2e7",
  red = "#f38ba8",
  white = "#bac2de",
  yellow = "#f9e2af",

  -- catppuccin uses the same color codes for normal and bright color variants, but distinguishes them with bold style.
  bold_bright_colors = true,

  -- extra colors not mapped to ansi colors
  rosewater = "#f5e0dc",
  flamingo = "#f2cdcd",
  pink = "#f5c2e7",
  mauve = "#cba6f7",
  maroon = "#eba0ac",
  peach = "#fab387",
  teal = "#94e2d5",
  sky = "#89dceb",
  sapphire = "#74c7ec",
  lavender = "#b4befe",
  text = "#cdd6f4",
  ['subtext 1'] = "#bac2de",
  ['subtext 0'] = "#a6adc8",
  ['overlay 2'] = "#9399b2",
  ['overlay 1'] = "#7f849c",
  ['overlay 0'] = "#6c7086",
  ['surface 2'] = "#585b70",
  ['surface 1'] = "#45475a",
  ['surface 0'] = "#313244",
  base = "#1e1e2e",
  mantle = "#181825",
  crust = "#11111b",
}

for k, v in pairs(catppuccin_mocha) do
  vv.options.theme[k] = v
end

