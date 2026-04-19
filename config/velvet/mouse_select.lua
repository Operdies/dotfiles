-- Missing before upstreaming:

-- 1. automatically start copy-mode when clicking a window with no mouse
-- handling
-- 2. don't automatically close the overlay and copy on mouse release. Add
-- a temporary ctrl-c / ctrl-shift-c keybind (configurable)
-- 3. inhibit keymap (passthrough) while overlay is active. trigger on
-- vv.async.wait(). Restore keymap in defer.
-- 4. pause window scrolling while overlay is active (C support needed)
-- 5. keymap for copying without the mouse: start at cursor; v/V/<C-v>
-- enters visual/linewise/blockwise mode; hjkl/arrow keys moves the cursor;
-- y / ctrl-c copies; cursor position is displayed on overlay. In cursor
-- mode, the cursor cannot leave the active window. Clicking a different
-- window with the mouse transfers the cursor to that window

-- some behaviors (1), keybinds (2, 5) should be configurable.
-- add velvet.copy_mode.options which is provided through a setup() function.

local win_api = require('velvet.window')

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

  local ov = win_api.create()

  -- put selection overlay on top of everything else to capture mouse events
  ov:set_z_index(vv.z_hint.overlay)
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
    for _, win in ipairs(win_api.get_window_at_coordinate(cord)) do
      if win ~= ov then return win end
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
      ov:draw(line.text)
    end
  end

  local function submit()
    if not selection then return nil end
    local ranges = get_selection_ranges()
    if not ranges then return end
    local lines = {}
    if blockwise then
      for _, r in ipairs(ranges) do
        local line = vv.api.window_get_text(selection.id, { top = r.row, height = 1, left = r.col1, width = r.col2 - r.col1 + 1 })[1]
        lines[#lines + 1] = line.text:match('(.-)%s*$')
      end
    else
      local wrapping = false
      for _, r in ipairs(ranges) do
        local line = vv.api.window_get_text(selection.id, { top = r.row, height = 1, left = r.col1, width = r.col2 - r.col1 + 1 })[1]
        local text = line.wraps and line.text or line.text:match('(.-)%s*$')
        local index = wrapping and #lines or #lines + 1
        if wrapping then text = lines[index] .. text end
        lines[index] = text
        wrapping = line.wraps
      end
      if #lines > 0 then lines[#lines] = lines[#lines]:match('(.-)%s*$') end
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
        local ok, err = pcall(submit)
        if not ok then vv.log(err, 'error') end
        ov:close()
      end
    end
  end)
end

local function mouse_copy_async()
  local blockwise = false
  local function local_to_global(id, cord)
    local geom = vv.api.window_get_geometry(id)
    return { col = geom.left + cord.col - 1, row = geom.top + cord.row - 1 }
  end
  local function global_to_local(id, cord)
    local geom = vv.api.window_get_geometry(id)
    return { col = 1 + cord.col - geom.left, row = 1 + cord.row - geom.top }
  end

  local ov = win_api.create()

  -- put selection overlay on top of everything else to capture mouse events
  ov:set_z_index(vv.z_hint.overlay)
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
    for _, win in ipairs(win_api.get_window_at_coordinate(cord)) do
      if win ~= ov then return win end
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
      ov:draw(line.text)
    end
  end

  local function submit()
    if not selection then return nil end
    local ranges = get_selection_ranges()
    if not ranges then return end
    local lines = {}
    if blockwise then
      for _, r in ipairs(ranges) do
        local line = vv.api.window_get_text(selection.id, { top = r.row, height = 1, left = r.col1, width = r.col2 - r.col1 + 1 })[1]
        lines[#lines + 1] = line.text:match('(.-)%s*$')
      end
    else
      local wrapping = false
      for _, r in ipairs(ranges) do
        local line = vv.api.window_get_text(selection.id, { top = r.row, height = 1, left = r.col1, width = r.col2 - r.col1 + 1 })[1]
        local text = line.wraps and line.text or line.text:match('(.-)%s*$')
        local index = wrapping and #lines or #lines + 1
        if wrapping then text = lines[index] .. text end
        lines[index] = text
        wrapping = line.wraps
      end
      if #lines > 0 then lines[#lines] = lines[#lines]:match('(.-)%s*$') end
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
        local ok, err = pcall(submit)
        if not ok then vv.log(err, 'error') end
        ov:close()
      end
    end
  end)
end

--- @return string text selection
-- local function mouse_select_async()
--   local ov = win_api.create()
--   while true do
--   end
-- end

return {
  select_async = mouse_copy_async,
  select_and_copy = function() 
    mouse_copy(vv.api.clipboard_set)
  end
}
