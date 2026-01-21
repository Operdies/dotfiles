local vv = require('velvet')
require('velvet.default_config')

local home = os.getenv("HOME"):gsub("/$", "")
local map = vv.api.keymap_set
local rmap = function(keys, action) vv.api.keymap_set(keys, action, { repeatable = true }) end
local function spawn(cmd) return vv.api.window_create_process(cmd) end

rmap("<C-x>b", function() spawn("bash") end)
map("<C-x>K", function() vv.api.window_close(vv.api.get_focused_window()) end)

map("<C-x>r", function() 
  package.loaded['velvet.default_options'] = nil
  package.loaded['velvet.default_config'] = nil
  package.loaded['velvet.events'] = nil
  package.loaded['velvet.window'] = nil
  package.loaded['velvet.layout.dwm'] = nil
  package.loaded['paint'] = nil
  package.loaded['coffee'] = nil
  package.loaded['logpanel'] = nil
  vv.events = require('velvet.events')

  for _, id in ipairs(vv.api.get_windows()) do
    if vv.api.window_is_lua(id) then pcall(vv.api.window_close, id) end
  end
  require('velvet.default_options')
  dofile(home .. "/.config/velvet/init.lua") 
end)

local dwm = require('velvet.layout.dwm')
map("<M-->", function() dwm.inc_inactive_dim(0.05) end)
map("<M-=>", function() dwm.inc_inactive_dim(-0.05) end)

map("<C-x>paint", require('paint').create_paint)
require('coffee').enable()

local event_manager = vv.events.create_group('close_if_all_exited', true)
event_manager.window_closed = function()
  for _, id in ipairs(vv.api.get_windows()) do
    if vv.api.window_is_valid(id) and not vv.api.window_is_lua(id) then return end
  end
  vv.api.quit()
end

local logpanel = require('logpanel')
map('<M-x>logs', logpanel.toggle)
logpanel.enable()

event_manager.pre_render = function(args)
  dbg({ render_at = args.time / 1000, cause = args.cause }, { newline = ' ', indent = '' })
end

vv.options.theme = require('velvet.themes').gruvbox.dark
