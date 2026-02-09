local vv = require('velvet')
require('velvet.default_config')
local dwm = require('velvet.layout.dwm')
local keymap = require('velvet.keymap')

local home = os.getenv("HOME"):gsub("/$", "")
local map = keymap.set

map("<C-x>K", function() vv.api.window_close(vv.api.get_focused_window()) end)
map("<C-x>z", function() dwm.toggle_arrange() end)
vv.options.key_repeat_timeout = 300

map("<M-->", function() dwm.inc_inactive_dim(0.05) end)
map("<M-=>", function() dwm.inc_inactive_dim(-0.05) end)

local paint = require('paint')
map("<C-x>paint", paint.create_paint)
require('coffee').enable()


local logpanel = require('logpanel')
map('<M-x>logs', logpanel.toggle)

local event_manager = vv.events.create_group('debug.log_render_timing', true)
event_manager.pre_render = function(args)
  dbg({ render_at = args.time / 1000, cause = args.cause }, { newline = ' ', indent = '' })
end

local velvet_window = require('velvet.window')

map('<C-x>w', function()
  local visible_indicator =     "(*) "
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

  pick.select(items, {
    on_choice = function(sel)
      sel.win:focus()
      dwm.make_visible(sel.win)
    end,
    prompt = "Focus window: ",
    initial_selection = initial_index,
  })
end)

require('clock')
vv.options.theme = require('velvet.themes').catppuccin.mocha

local any_processes = false
for _, id in ipairs(vv.api.get_windows()) do
  if not vv.api.window_is_lua(id) then any_processes = true end
end

if not any_processes then
  velvet_window.create_process('zsh')
end

-- I am too used to the position of these keys on MacOS
keymap.remap_key('§', '`')
keymap.remap_key('±', '~')
