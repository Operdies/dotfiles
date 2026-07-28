local options = {
    prefix = '<C-x>',
    startup = { spawn_shell = true },
    shutdown = { on_last_window_exit = true },
}

-- enable all velvet default options
local preset = require('velvet.presets.dwm').setup(options)
local keymap = require('velvet.keymap')

-- set up two quake-style terminals
local quake = require('velvet.extras.quake')
local quake_shell = quake.create('zsh', 'default')
local quake_lazygit = quake.create('lazygit', 'lazygit')

-- load extra theme colors
require('catppuccin_mocha')

--- @param lhs string
--- @param func fun()
--- @param opt string|velvet.keys.set.options
local map = function(lhs, func, opt) keymap:set(lhs, func, type(opt) == 'table' and opt or { description = opt }) end

--- @param lhs string
--- @param func fun()
--- @param opt string|velvet.keys.set.options
local map_prefix = function(lhs, func, opt) map(options.prefix .. lhs, func, opt) end


map("<M-`>", function() require('velvet.layout.dwm').select_previous_view() end, { description = "Select the previous view" })
map_prefix("K", function() vv.api.window_close(vv.api.get_focused_window()) end, "Close focused window")
map_prefix("<C-\\>", quake_shell.toggle, "Toggle Zsh Quake")
map_prefix("<C-]>", quake_lazygit.toggle, "Toggle Lazygit Quake")
map_prefix('s', function() require('pickers.session').pick_session() end, "Switch session")
map_prefix('w', function() require('pickers.window').pick() end, "Start window picker")

-- I am too used to the position of these keys on MacOS
keymap:remap_key('§', '`')
keymap:remap_key('±', '~')


-- laptop battery indicator, dependent on the 'acpi' binary being available
local ok, mod = pcall(require, 'status.acpi')
if ok then
  mod.setup(preset.statusbar)
end

-- machine-specific config, not checked in
ok, mod = pcall(require, 'private')
if ok then
  mod.setup(options, preset)
end

local log_connected = require('cli-logger').on_logger_connected
log_connected:wait()
local toast = require('toast')
toast('info', 'logger connected!')

