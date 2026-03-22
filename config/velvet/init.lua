local vv = require('velvet')
local map_prefix = "<C-x>"
require('velvet.default_config').setup({ prefix = map_prefix })

local dwm = require('velvet.layout.dwm')
local keymap = require('velvet.keymap')

local home = os.getenv("HOME"):gsub("/$", "")
local map = keymap.set

map(map_prefix .. "K", function() vv.api.window_close(vv.api.get_focused_window()) end)
map(map_prefix .. "z", function() dwm.toggle_arrange() end)
vv.options.key_repeat_timeout = 300

map("<M-->", function() dwm.inc_inactive_dim(0.05) end)
map("<M-=>", function() dwm.inc_inactive_dim(-0.05) end)

local paint = require('paint')
map(map_prefix .. "paint", paint.create_paint)
-- require('coffee').enable()


local logpanel = require('logpanel')
map('<M-x>logs', logpanel.toggle)
-- logpanel.enable()

local event_manager = vv.events.create_group('debug.log_render_timing', true)
event_manager.pre_render = function(args)
  dbg({ render_at = args.time / 1000, cause = args.cause }, { newline = ' ', indent = '' })
end

local velvet_window = require('velvet.window')

map(map_prefix .. 'w', function()
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

-- I am too used to the position of these keys on MacOS
keymap.remap_key('§', '`')
keymap.remap_key('±', '~')

do
  local quake_evt = vv.events.create_group("quake_resize_event", true)

  --- @type velvet.window
  local quakeHost = nil
  --- @type velvet.window
  local quake = nil

  local function get_size()
    local screen_size = vv.api.get_screen_geometry()
    local minwidth = 3
    local width = screen_size.width + 2
    if width < minwidth then width = minwidth end
    local height = screen_size.height // 3
    local minheight = math.min(40, screen_size.height)
    if height < minheight then height = minheight end
    local hostSize = {
      width = width,
      height = height,
      left = -1,
      top = 1 + screen_size.height - height,
    }
    local winSize = {
      width = hostSize.width - 2,
      height = hostSize.height - 2,
      left = hostSize.left + 1,
      top = hostSize.top + 1,
    }
    return hostSize, winSize
  end

  local function setsize()
    quake:set_frame_enabled(true)
    quake:set_frame_color('magenta')
    quake:set_z_index(99999)
    quake:set_title("─Quake")
    quake:set_opacity(0.7)
    quakeHost:set_background_color('black')
    quakeHost:set_opacity(0.1)
    quakeHost:set_z_index(quake:get_z_index())
    local hostSize, winSize = get_size()
    quakeHost:set_geometry(hostSize)
    quake:set_geometry(winSize)
    quakeHost:clear()
  end

  local function create_quake()
    quakeHost = velvet_window.create()
    quake = quakeHost:create_child_process_window("zsh", { working_directory = vv.api.window_get_working_directory(vv.api.get_focused_window()) })
    quake_evt.screen_resized = setsize
    quake:set_visibility(false)
    quakeHost:set_visibility(false)

    quake:on_window_closed(function() quakeHost:close() end)
    quake:on_window_moved(function(_, args)
      local geom = args.new_size
      geom.height = geom.height + 2
      geom.width = geom.width + 2
      geom.left = geom.left - 1
      geom.top = geom.top - 1
      quakeHost:set_geometry(geom)
    end)
    setsize()
  end

  local prevFocus = nil
  local visible = false

  local anim = require('velvet.stdlib.animation')

  local anim_duration = 200
  local function hide()
    if prevFocus and vv.api.window_is_valid(prevFocus) then
      vv.api.set_focused_window(prevFocus)
      prevFocus = nil
    end

    local screen = vv.api.get_screen_geometry()
    local _, new_size = get_size()
    new_size.top = screen.height
    anim.animate(quake.id, new_size, anim_duration, {
      easing_function = anim.easing.spring,
      on_completed = function()
        quake:set_visibility(false)
        quakeHost:set_visibility(false)
      end
    })
    visible = false
  end

  local function show()
    prevFocus = vv.api.get_focused_window()
    quake:set_visibility(true)
    quakeHost:set_visibility(true)
    quake:focus()
    local _, new_size = get_size()
    anim.animate(quake.id, new_size, anim_duration, { easing_function = anim.easing.spring })
    visible = true
  end

  local function toggle()
    if quake == nil or not quake:valid() then
      visible = false
      if quakeHost and quakeHost:valid() then quakeHost:close() end
      create_quake()
    end
    if visible then hide() else show() end
  end

  map("<F1>", toggle)
end
