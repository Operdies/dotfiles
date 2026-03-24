local velvet_window = require('velvet.window')
local quake_evt = vv.events.create_group("quake_resize_event", true)

--- @type velvet.window
local quakeHost = nil
--- @type velvet.window
local quake = nil

local function get_size()
  local screen_size = vv.api.get_screen_geometry()
  local minwidth = 3
  local width = screen_size.width
  if width < minwidth then width = minwidth end
  local height = screen_size.height // 3
  local minheight = math.min(40, screen_size.height)
  if height < minheight then height = minheight end
  return {
    width = width,
    height = height,
    left = 1,
    top = 1 + screen_size.height - height,
  }
end

local function setsize()
  quake:set_frame_enabled(true)
  quake:set_frame_color('magenta')
  quake:set_z_index(99999)
  quake:set_title("Quake")
  quake:set_opacity(0.7)
  quakeHost:set_background_color('black')
  quakeHost:set_opacity(0.1)
  quakeHost:set_z_index(quake:get_z_index())
  local winSize = get_size()
  quake:set_geometry(winSize)
  quakeHost:clear()
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
  local new_size = get_size()
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
  local focus = vv.api.get_focused_window()
  if focus ~= quake.id then prevFocus = focus end
  quake:set_visibility(true)
  quakeHost:set_visibility(true)
  quake:focus()
  local new_size = get_size()
  anim.animate(quake.id, new_size, anim_duration, { easing_function = anim.easing.spring })
  visible = true
end

local function create_quake()
  quakeHost = velvet_window.create()
  quake = quakeHost:create_child_process_window("zsh",
    { working_directory = vv.api.window_get_working_directory(vv.api.get_focused_window()) })
  quake_evt.screen_resized = setsize
  quake:set_visibility(false)
  quakeHost:set_visibility(false)

  quake:on_window_closed(function() quakeHost:close() end)
  quake:on_window_moved(function(_, args) quakeHost:set_geometry(args.new_size) end)
  quake:on_focus_changed(function(_, args)
    if args.new == quake then show() end
    if args.new == quake then
      if args.old and args.old ~= quake then prevFocus = args.old.id end
    end
  end)
  setsize()
end

local function toggle()
  if quake == nil or not quake:valid() then
    visible = false
    if quakeHost and quakeHost:valid() then quakeHost:close() end
    create_quake()
  end
  if visible then hide() else show() end
end

return {
  hide = hide,
  show = show,
  toggle = toggle,
}
