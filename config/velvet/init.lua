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
    quake = quakeHost:create_child_process_window("zsh",
      { working_directory = vv.api.window_get_working_directory(vv.api.get_focused_window()) })
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

local function overlay()
  local blockwise = false
  local function local_to_global(id, cord)
    local geom = vv.api.window_get_geometry(id)
    return { col = geom.left + cord.col - 1, row = geom.top + cord.row - 1 }
  end
  local function global_to_local(id, cord)
    local geom = vv.api.window_get_geometry(id)
    return { col = 1 + cord.col - geom.left, row = 1 + cord.row - geom.top }
  end

  local ov = velvet_window.create()

  -- put selection overlay on top of everything else to capture mouse events
  ov:set_z_index(100000)
  ov:set_cursor_visible(false)

  -- only highlight selected region -- the rest of the window is completely opaque
  ov:set_opacity(0.1)
  ov:set_transparency_mode('clear')

  -- cover the entire screen
  local sz = vv.api.get_screen_geometry()
  ov:set_geometry({ left = 1, top = 1, width = sz.width, height = sz.height })
  ov:focus()

  local function get_topmost_window_at_cord(cord)
    -- find the topmost window in the Z order which is underneath the indicated coordinate.
    local windows = vv.api.get_windows()
    local lst = {}
    for _, id in ipairs(windows) do
      local win = velvet_window.from_handle(id)
      if id ~= ov.id and win:get_visibility() then
        local z = vv.api.window_get_z_index(id)
        local g = vv.api.window_get_geometry(id)
        lst[#lst + 1] = { win = win, z = z, geom = g }
      end
    end
    table.sort(lst, function(x, y) return x.z > y.z end)
    for _, it in ipairs(lst) do
      if cord.col >= it.geom.left and cord.col < it.geom.left + it.geom.width
          and cord.row >= it.geom.top and cord.row < it.geom.top + it.geom.height then
        return it.win
      end
    end
  end

  local selection = nil
  local dragging = false

  local function draw()
    if not selection then return end
    ov:clear_background_color()
    ov:clear()
    local linewise_bg = '#ffffffc0'
    local blockwise_bg = '#ffffffc0'
    local bg = blockwise and blockwise_bg or linewise_bg
    ov:set_background_color(bg)

    local geom = vv.api.window_get_geometry(selection.id)
    local col1 = selection.start.col
    local col2 = selection._end.col
    local row1 = selection.start.row
    local row2 = selection._end.row

    if col1 > col2 then col1, col2 = col2, col1 end
    if row1 > row2 then row1, row2 = row2, row1 end

    -- TODO: This makes sense for block select, but is misguided. It makes line select much more complicated than it needs to be
    -- We need to collect a list of {{start, end}} pairs and fetch the text linewise from the window.
    -- We also need to actually draw the selected text on the overlay, otherwise behavior gets a bit weird with double width chars
    if col1 < 1 then col1 = 1 end
    if col2 > geom.width then col2 = geom.width end
    if row1 < 1 then row1 = 1 end
    if row2 > geom.height then row2 = geom.height end

    local region = { left = col1, width = col2 - col1, top = row1, height = 1 + row2 - row1 }
    local text = vv.api.window_get_text(selection.id, region)
    for i, line in ipairs(text) do
      dbg(("%d) %s"):format(i, line))
    end

    do
      local c_start_orig = global_to_local(ov.id, local_to_global(selection.id, selection.start))
      local c_end_orig = global_to_local(ov.id, local_to_global(selection.id, selection._end))

      local c_start = { col = col1, row = row1 }
      local c_end = { col = col2, row = row2 }
      c_start = global_to_local(ov.id, local_to_global(selection.id, c_start))
      c_end = global_to_local(ov.id, local_to_global(selection.id, c_end))

      if blockwise then
        for row = c_start.row, c_end.row do
          ov:set_cursor(c_start.col, row)
          local str = (' '):rep(1 + c_end.col - c_start.col)
          ov:draw(str)
        end
      else
        local upleft, bottomright = c_start_orig.col, c_end_orig.col
        if c_start_orig.row > c_end_orig.row then
          -- when multiple lines are selected, the start/end column depends on
          -- the direction of the selection
          upleft, bottomright = bottomright, upleft
        end
        for row = c_start.row, c_end.row do
          local start_col = (row == c_start.row) and upleft or geom.left
          local end_col   = (row == c_end.row) and 1 + bottomright or geom.width + geom.left
          if c_start_orig.row == c_end_orig.row then
            -- special case when only one line is selected
            start_col, end_col = c_start.col, c_end.col
          end
          ov:set_cursor(start_col, row)
          ov:draw((' '):rep(end_col - start_col))
        end
      end
    end
  end

  ov:on_window_on_key(function(_, args)
    -- close on escape
    if args.key.codepoint == 27 then
      ov:close()
    elseif dragging then
      -- detect alt without moving the mouse. this only works when the hosting terminal supports kitty keys
      blockwise = args.key.modifiers.alt and true or false
      draw()
    end
  end)

  ov:on_mouse_move(function(_, move)
    if not selection or not dragging then return end
    selection._end = global_to_local(selection.id, local_to_global(move.win_id, move.pos))
    blockwise = move.modifiers.alt and true or false
    draw()
  end)

  ov:on_mouse_click(function(_, click)
    if click.mouse_button == 'left' then
      if click.event_type == 'mouse_down' then
        local win = get_topmost_window_at_cord(local_to_global(click.win_id, click.pos))
        if win then
          dragging = true
          blockwise = click.modifiers.alt and true or false
          local pos = global_to_local(win.id, local_to_global(click.win_id, click.pos))
          selection = { id = win.id, start = pos, _end = pos }
          draw()
        end
      else
        dragging = false
      end
    end
  end)
end

map("<C-x>v", overlay)
logpanel.enable()
