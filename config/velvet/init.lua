local map_prefix = "<C-x>"
local options = {
    prefix = map_prefix,
    startup = { spawn_shell = true },
    shutdown = { on_last_window_exit = true },
}
local preset = require('velvet.presets.dwm').setup(options)

-- values stored in |storage| will survive reloads.
local storage = require('velvet.runtime_storage').create("config")

local keymap = require('velvet.keymap')

--- @param lhs string
--- @param func fun()
--- @param opt string|velvet.keys.set.options
local map = function(lhs, func, opt) keymap:set(lhs, func, type(opt) == 'table' and opt or { description = opt }) end

map(map_prefix .. "K", function() vv.api.window_close(vv.api.get_focused_window()) end, "Close focused window")

local dwm = require('velvet.layout.dwm')

do
  local logpanel = require('velvet.diagnostics.logpanel')
  local function update_logpanel_state()
    if storage.logpanel_enabled then
      logpanel.enable()
    else
      logpanel.disable()
    end
  end
  local function toggle_logpanel()
    storage.logpanel_enabled = not storage.logpanel_enabled
    update_logpanel_state()
  end
  map('<M-x>logs', toggle_logpanel, "Toggle logpanel")
  update_logpanel_state()
end


map(map_prefix .. 'w', function() require('pickers.window').pick() end, "Start window picker")


-- I am too used to the position of these keys on MacOS
keymap:remap_key('§', '`')
keymap:remap_key('±', '~')

do
  local quake = require('velvet.extras.quake')
  local quake_shell = quake.create('zsh', 'default')
  local quake_lazygit = quake.create('lazygit', 'lazygit')
  map(map_prefix .. "<C-\\>", quake_shell.toggle, "Toggle Zsh Quake")
  map(map_prefix .. "<C-]>", quake_lazygit.toggle, "Toggle Lazygit Quake")
end


map(map_prefix .. 's', function() require('pickers.session').pick_session() end, "Switch session")
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

--- disabled theme {{{1
-- most of this I don't really need but they all serve as great examples of how to
-- do cool things with velvet so I will keep them around, but disabled

-- map("<M-->", function() dwm.inc_inactive_dim(-1.05) end, "Increase inactive dim")
-- map("<M-=>", function() dwm.inc_inactive_dim(-0.05) end, "Decrease inactive dim")
-- local paint = require('paint')
-- map(map_prefix .. "paint", paint.create_paint, "Open paint window")
-- require('coffee').enable()
-- require('log-events')
-- local disable_keymap = require('disable_keymap')
-- map("<C-x><space>", disable_keymap, "Temporarily disable keymap")
-- require('nordic_keys')


-- Modeline {{{1
-- vim: fdm=marker shiftwidth=2 foldlevel=0
