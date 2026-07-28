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


local velvet_window = require('velvet.window')

map(map_prefix .. 'w', function()
  local visible_indicator = "(*) "
  local not_visible_indicator = "    "
  local pick = require('velvet.pick')
  local lst = vv.api.get_windows()
  table.sort(lst, function(a, b) return a < b end)
  local items = {}
  local initial_index = -1
  local current_focus = vv.api.get_focused_window()
  for _, id in ipairs(lst) do
    local w = velvet_window.from_handle(id)
    if not w:is_lua() and not w:get_parent() then
      local display = w:get_friendly_title()
      local prefix = w:get_visibility() and visible_indicator or not_visible_indicator
      items[#items + 1] = { text = prefix .. display, win = w }
      if id == current_focus then initial_index = #items end
    end
  end

  local underlay = nil
  local prev_preview = { win = nil, z = nil, visible = nil, alpha = nil }
  local function restore_prev()
    local w = prev_preview and prev_preview.win
    if w and w:valid() then
      w:set_z_index(prev_preview.z)
      w:set_visibility(prev_preview.visible)
      w:set_alpha(prev_preview.alpha)
    end
  end
  local function dispose()
    restore_prev()
    if underlay and underlay.close then underlay:close() end
  end
  pick.select(items, {
    on_preview = function(sel)
      local picker = pick.get_active_picker()
      if not underlay then
        underlay = picker:create_child_window()
        underlay:set_z_index(picker:get_z_index() - 2)
      end
      local ts = vv.api.get_screen_geometry()
      underlay:set_geometry({left = 1, top = 1, width = ts.width, height = ts.height })
      underlay:set_background_color(vv.options.theme.background)
      underlay:clear()
      restore_prev()
      prev_preview = { win = sel.win, z = sel.win:get_z_index(), visible = sel.win:get_visibility(), alpha = sel.win:get_alpha() }
      sel.win:set_z_index(picker:get_z_index() - 1)
      sel.win:set_visibility(true)
      sel.win:set_alpha(1.0)
      if sel.win.borders then sel.win:set_frame_color('magenta') end
    end,
    on_cancel = function()
      dispose()
    end,
    on_choice = function(sel)
      sel.win:focus()
      dwm.make_visible(sel.win)
      dispose()
    end,
    prompt = "Focus window: ",
    initial_selection = initial_index,
  })
end, "Start window picker")


-- I am too used to the position of these keys on MacOS
keymap:remap_key('§', '`')
keymap:remap_key('±', '~')

local quake = require('velvet.extras.quake')
local quake1 = quake.create('zsh', 'default')
local lazygit = quake.create('lazygit', 'lazygit')
map(map_prefix .. "<C-\\>", quake1.toggle, "Toggle Zsh Quake")
map(map_prefix .. "<C-]>", lazygit.toggle, "Toggle Lazygit Quake")


map("<M-`>", dwm.select_previous_view, { description = "Select the previous view" })


local log_connected = require('cli-logger').on_logger_connected

map(map_prefix .. 's', require('pick_session').pick_session, "Switch session")

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
