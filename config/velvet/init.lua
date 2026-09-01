local options = {
  prefix = '<C-x>',
  startup = { spawn_shell = true },
  shutdown = { on_last_window_exit = true },
  mouse = { automatic_selection = true },
}

-- enable all velvet default options
local preset = require('velvet.presets.dwm').setup(options)
local keymap = require('velvet.keymap')

-- track how many times config was reloaded.
-- this is mostly useful for detecting if this is the first load or not.
local store = require('velvet.storage').create('config')
local reload_counter = store.reload_counter or 0
store.reload_counter = reload_counter + 1

-- set up two quake-style terminals
local quake = require('velvet.extras.quake')
local quake_shell = quake.create('zsh', 'default')
local quake_lazygit = quake.create('lazygit', 'lazygit')

-- load extra theme colors
require('theme.catppuccin_mocha')

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

-- local toast = require('experimental.toast')
-- if reload_counter > 0 then
--   toast("reload", "config reloaded! (" .. reload_counter .. ")", { duration = 2 })
-- end

-- laptop battery indicator, dependent on the 'acpi' binary being available
local err
local ok, mod = pcall(require, 'status.acpi')
if ok then
  ok, err = pcall(mod.setup, preset.statusbar)
  if not ok then printerr(err) end
end

do
  -- machine-specific config, not checked in
  local velvet_private = (os.getenv('HOME'):gsub('/$', '') .. '/') .. '.config/velvet-private/'
  package.path = package.path .. ';' .. (velvet_private .. '?.lua;') .. (velvet_private .. '?/init.lua;')
  ok, mod = pcall(require, 'private')
  if ok then
    ok, err = pcall(mod.setup, options, preset)
    if not ok then printerr(err) end
  end
end

local bar = preset.statusbar
local c = bar:get_left()
table.insert(c, (require('status.render_counter')))
table.insert(c, (require('status.vm_memory')))
table.insert(c, (require('status.cpu_time')))
table.insert(c, (require('status.uptime')))
bar:set_left(c)

-- local toast = require('experimental.toast')
-- require('velvet.cli.log').on_logger_connected:wait()
-- toast('log', 'logger connected!')

