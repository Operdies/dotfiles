local vv = require('velvet')
require('velvet.default_config')
local dwm = require('velvet.layout.dwm')
local keymap = require('velvet.keymap')

local home = os.getenv("HOME"):gsub("/$", "")
local map = keymap.set

map("<C-x>K", function() vv.api.window_close(vv.api.get_focused_window()) end)
map("<C-x>z", function() dwm.toggle_arrange() end)
vv.options.key_repeat_timeout = 300

map("<C-x>r", function() 
  package.loaded['velvet.default_options'] = nil
  package.loaded['velvet.default_config'] = nil
  package.loaded['velvet.events'] = nil
  package.loaded['velvet.window'] = nil
  package.loaded['velvet.keymap'] = nil
  package.loaded['velvet.layout.dwm'] = nil
  package.loaded['paint'] = nil
  package.loaded['coffee'] = nil
  package.loaded['logpanel'] = nil
  package.loaded['clock'] = nil
  vv.events = require('velvet.events')

  for _, id in ipairs(vv.api.get_windows()) do
    if vv.api.window_is_lua(id) then pcall(vv.api.window_close, id) end
  end
  require('velvet.default_options')
  dofile(home .. "/.config/velvet/init.lua") 
end)

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

local windows = require('velvet.window')

--- @type velvet.window | nil
local picker = nil
--- @param on_pick fun(win: velvet.window) pick callback
local pick_window = function(on_pick)
  local evt = require('velvet.events')
  local e = evt.create_group('custom.pick_window', true)

  picker = picker or windows.create()
  local winlist = vv.api.get_windows()
  local sz = vv.api.get_screen_geometry()
  local width = 50
  local height = #winlist
  local geom = { left = sz.width // 2 - width // 2, width = width, height = height, top = sz.height // 2 - height // 2 }
  picker:set_geometry(geom)
  picker:set_frame_enabled(true)
  picker:set_frame_color('red')
  picker:set_z_index(vv.layers.popup)
  picker:clear_background_color()
  picker:set_opacity(0.8)
  picker:set_transparency_mode('all')
  picker:set_cursor_visible(false)
  picker:set_visibility(true)

  local prev_focus = vv.api.get_focused_window()
  picker:focus()

  local tmp = vv.options.focus_follows_mouse
  vv.options.focus_follows_mouse = false
  local function dispose()
    vv.options.focus_follows_mouse = tmp
    evt.delete_group(e)
    picker:set_visibility(false)
    if vv.api.window_is_valid(prev_focus) then vv.api.set_focused_window(prev_focus) end
  end


  local index = 1
  local snapshot = {}
  local filter = ''

  local function draw()
    if not picker:valid() then return end
    picker:set_title('Pick: ' .. filter)
    local lst = vv.api.get_windows()
    table.sort(lst, function(a, b) return a < b end)
    local i = 1
    snapshot = {}
    picker:set_cursor(1, 1)
    picker:clear_background_color()
    picker:clear()
    local titles = {}
    for _, win in ipairs(lst) do
      local w = windows.from_handle(win)
      if not w:is_lua() then
        local title = w:get_friendly_title()
        local display = ('%d - %s'):format(w.id, title)
        local case_sensitive = filter:lower() ~= filter
        local search = case_sensitive and display or display:lower()
        if search:find(filter, 1, true) then
          if #display > width then width = #display end
          snapshot[i] = w
          titles[i] = display
          i = i + 1
        end
      end
    end
    height = #snapshot
    local geom2 = { left = sz.width // 2 - width // 2, width = width, height = height, top = sz.height // 2 - height // 2 }
    picker:set_geometry(geom2)
    picker:set_foreground_color('blue')
    if index > #snapshot then index = #snapshot end
    if index < 1 then index = 1 end
    for idx, _ in ipairs(snapshot) do
      if idx == index then
        picker:set_foreground_color('red')
      else
        picker:set_foreground_color('blue')
      end
      picker:set_cursor(1, idx)
      picker:draw(("\x1b[K%s"):format(titles[idx]))
    end
  end

  local function submit()
    dispose()
    if index > 0 and index <= #snapshot then
      on_pick(snapshot[index])
    end
  end

  --- @param args velvet.api.window.on_key.event_args
  picker:on_window_on_key(function(args)
    local k = args.key
    if k.event_type == 'press' or k.event_type == 'repeat' then
      if k.name == 'ESC' or
        (k.codepoint == string.byte('c') and k.modifiers.control)
      then
        dispose()
        return
      end
      if k.name == 'DOWN' or
        (k.codepoint == string.byte('n') and k.modifiers.control) then
        index = 1 + (index % #snapshot)
      elseif k.name == 'UP' or
        (k.codepoint == string.byte('p') and k.modifiers.control) then
        index = index - 1
        if index == 0 then index = #snapshot end
      elseif k.name == 'ENTER' then
        submit()
        return
      elseif k.name == 'BACKSPACE' then
        if #filter > 0 then
          filter = filter:sub(1, -2)
        end
      elseif k.codepoint == string.byte('w') and k.modifiers.control then
        filter = ''
      elseif k.codepoint < 128 then
        local cp = k.alternate_codepoint > 0 and k.alternate_codepoint or k.codepoint
        local ch = utf8.char(cp)
        filter = filter .. ch
      end
      draw()
    end
  end)

  picker:on_mouse_click(function(_, args)
    if args.mouse_button == 'left' and args.event_type == 'mouse_down' then
      if args.pos.row <= #snapshot then
        index = args.pos.row
        submit()
      end
    end
  end)
  picker:on_mouse_move(function(_, args)
    if args.pos.row <= #snapshot then
      index = args.pos.row
      draw()
    end
  end)

  e.window_focus_changed = function(args)
    if args.new_focus ~= picker.id then
      dispose()
    end
  end
  draw()
end

map('<C-x>w', function() 
  pick_window(function(win)
    win:focus()
    dwm.make_visible(win)
  end)
end)

require('clock')
vv.options.theme = require('velvet.themes').catppuccin.mocha

local any_processes = false
for _, id in ipairs(vv.api.get_windows()) do
  if not vv.api.window_is_lua(id) then any_processes = true end
end

if not any_processes then
  windows.create_process('zsh')
end
