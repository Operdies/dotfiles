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

-- I am too used to the position of these keys on MacOS
keymap.remap_key('§', '`')
keymap.remap_key('±', '~')

map("<F1>", require('quake').toggle)

--- @param on_select fun(text: string): nil
local function mouse_copy(on_select)
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
  local clear_bg = '#00000020'
  ov:set_background_color(clear_bg)
  ov:clear()

  -- cover the entire screen
  local sz = vv.api.get_screen_geometry()
  ov:set_geometry({ left = 1, top = 1, width = sz.width, height = sz.height })
  ov:focus()

  ov:on_focus_changed(function(_, args)
    if args.new ~= ov then ov:close() end
  end)

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

  local function get_selection_ranges()
    if not selection then return nil end
    local geom = vv.api.window_get_geometry(selection.id)
    if blockwise then
      local col1, col2 = selection.start.col, selection._end.col
      local row1, row2 = selection.start.row, selection._end.row
      if col1 > col2 then col1, col2 = col2, col1 end
      if row1 > row2 then row1, row2 = row2, row1 end
      local ranges = {}
      for row = row1, row2 do
        if row > geom.height then break end
        ranges[#ranges + 1] = { row = row, col1 = col1, col2 = col2 }
      end
      return ranges, geom
    else
      local start, _end = selection.start, selection._end
      if start.row > _end.row then start, _end = _end, start end
      local ranges = {}
      for row = start.row, _end.row do
        if row > geom.height then break end
        local col1 = row == start.row and start.col or 1
        local col2 = row == _end.row and _end.col or geom.width
        if start.row == _end.row and col1 > col2 then col1, col2 = col2, col1 end
        ranges[#ranges + 1] = { row = row, col1 = col1, col2 = col2 }
      end
      return ranges
    end
  end

  local function draw()
    if not selection then return end
    local ranges = get_selection_ranges()
    if not ranges then return end
    ov:set_background_color(clear_bg)
    ov:clear()
    local bg = vv.options.theme.foreground
    local fg = vv.options.theme.background
    ov:set_background_color(bg)
    ov:set_foreground_color(fg)
    for _, r in ipairs(ranges) do
      local line = vv.api.window_get_text(selection.id, { top = r.row, height = 1, left = r.col1, width = r.col2 - r.col1 + 1 })[1]
      local pos = local_to_global(selection.id, { col = r.col1, row = r.row })
      local gpos = global_to_local(ov.id, pos)
      ov:set_cursor(gpos.col, gpos.row)
      ov:draw(line)
    end
  end

  local function submit()
    if not selection then return nil end
    local ranges = get_selection_ranges()
    if not ranges then return end
    local lines = {}
    for _, r in ipairs(ranges) do
      local line = vv.api.window_get_text(selection.id, { top = r.row, height = 1, left = r.col1, width = r.col2 - r.col1 + 1 })[1]
      lines[#lines + 1] = line:match('(.-)%s*$')
    end
    if on_select then pcall(on_select, table.concat(lines, '\n')) end
    ov:close()
  end


  ov:on_window_on_key(function(_, args)
    -- close on escape
    if args.key.codepoint == 27 then
      ov:close()
    end
  end)

  ov:on_mouse_move(function(_, move)
    if not selection or not dragging then return end
    local geom = vv.api.window_get_geometry(selection.id)
    local sel = global_to_local(selection.id, local_to_global(move.win_id, move.pos))
    -- clamp column to window
    sel.col = math.max(math.min(geom.width, sel.col), 1)
    -- clamp row to height+1 -- this allows the user to select the full last row by dragging out of the window.
    -- special handling in get_selection_ranges to support this.
    sel.row = math.max(math.min(geom.height + 1, sel.row), 1)
    selection._end = sel
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
        pcall(submit)
        ov:close()
      end
    end
  end)
end

map("<C-x>v", function() mouse_copy(vv.api.clipboard_set) end)
