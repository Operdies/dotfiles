if vim.g.neovide then
  vim.o.guifont = "MesloLGS Nerd Font Mono:h14"
  vim.opt.linespace = 0
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
  vim.g.neovide_input_ime = false
  vim.g.neovide_hide_mouse_when_typing = true

  -- turn animations way down
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_position_animation_length = 0.1
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_cursor_animate_in_insert_mode = true

  -- window settings
  vim.g.neovide_window_blurred = true
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_normal_opacity = 0.8
  vim.g.neovide_show_border = true

  -- floating window settings
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_floating_corner_radius = 0.0

  -- catppuccin terminal colors
  vim.g.terminal_color_0 = "#45475a"
  vim.g.terminal_color_1 = "#f38ba8"
  vim.g.terminal_color_2 = "#a6e3a1"
  vim.g.terminal_color_3 = "#f9e2af"
  vim.g.terminal_color_4 = "#89b4fa"
  vim.g.terminal_color_5 = "#f5c2e7"
  vim.g.terminal_color_6 = "#94e2d5"
  vim.g.terminal_color_7 = "#bac2de"
  vim.g.terminal_color_8 = "#585b70"
  vim.g.terminal_color_9 = "#f38ba8"
  vim.g.terminal_color_10 = "#a6e3a1"
  vim.g.terminal_color_11 = "#f9e2af"
  vim.g.terminal_color_12 = "#89b4fa"
  vim.g.terminal_color_13 = "#f5c2e7"
  vim.g.terminal_color_14 = "#94e2d5"
  vim.g.terminal_color_15 = "#a6adc8"

  -- <Cmd> bindings for mac
  if vim.fn.has('mac') then
    local opts = { silent = true, noremap = true }
    vim.keymap.set('i', '<D-v>', '<C-r>+', opts)
    vim.keymap.set({ 'n', 'v' }, '<D-c>', '"+y', opts)
    vim.keymap.set({ 'n', 'v' }, '<D-v>', '"+p', opts)
    vim.keymap.set('t', '<D-v>', '<C-\\><C-o>"+p', opts)
    vim.keymap.set('n', '<D-s>', '<cmd>w<cr>', opts)
    vim.keymap.set('n', '<D-o>', '<cmd>w<cr><cmd>so %<cr>', opts)
  end
end
