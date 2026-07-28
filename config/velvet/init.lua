local prefix = "<C-x>"
local options = {
    prefix = prefix,
    startup = { spawn_shell = true },
    shutdown = { on_last_window_exit = true },
}
local preset = require('velvet.presets.dwm').setup(options)

local keymap = require('velvet.keymap')

--- @param lhs string
--- @param func fun()
--- @param opt string|velvet.keys.set.options
local map = function(lhs, func, opt) keymap:set(lhs, func, type(opt) == 'table' and opt or { description = opt }) end

--- @param lhs string
--- @param func fun()
--- @param opt string|velvet.keys.set.options
local map_prefix = function(lhs, func, opt) map(prefix .. lhs, func, opt) end


map_prefix("K", function() vv.api.window_close(vv.api.get_focused_window()) end, "Close focused window")

local dwm = require('velvet.layout.dwm')

map_prefix('w', function() require('pickers.window').pick() end, "Start window picker")


-- I am too used to the position of these keys on MacOS
keymap:remap_key('§', '`')
keymap:remap_key('±', '~')

do
  local quake = require('velvet.extras.quake')
  local quake_shell = quake.create('zsh', 'default')
  local quake_lazygit = quake.create('lazygit', 'lazygit')
  map_prefix("<C-\\>", quake_shell.toggle, "Toggle Zsh Quake")
  map_prefix("<C-]>", quake_lazygit.toggle, "Toggle Lazygit Quake")
end


map_prefix('s', function() require('pickers.session').pick_session() end, "Switch session")
map("<M-`>", dwm.select_previous_view, { description = "Select the previous view" })


local log_connected = require('cli-logger').on_logger_connected


require('catppuccin_mocha')

local ok, acpi = pcall(require, 'status.acpi')
if ok then
  acpi.setup(preset.statusbar)
end

-- machine-specific config, not checked in
local ok, private = pcall(require, 'private')
if ok then
  private.setup(options, preset)
end

log_connected:wait()
local toast = require('toast')
toast('info', 'logger connected!')

-- Modeline {{{1
-- vim: fdm=marker shiftwidth=2 foldlevel=0
