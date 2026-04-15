local map_prefix = "<C-x>"
require('velvet.presets.dwm').setup({ prefix = map_prefix, startup = { spawn_shell = true }, shutdown = { on_last_window_exit = true }})

-- values stored in |session| will survive reloads.
local session = require('velvet.session_storage').create("config")

local dwm = require('velvet.layout.dwm')
local keymap = require('velvet.keymap')

local home = os.getenv("HOME"):gsub("/$", "")

--- @param lhs string
--- @param func fun()
--- @param opt string|velvet.keys.set.options
local map = function(lhs, func, opt) keymap.set(lhs, func, type(opt) == 'table' and opt or { description = opt }) end

map(map_prefix .. "K", function() vv.api.window_close(vv.api.get_focused_window()) end, "Close focused window")

map("<M-->", function() dwm.inc_inactive_dim(0.05) end, "Increase inactive dim")
map("<M-=>", function() dwm.inc_inactive_dim(-0.05) end, "Decrease inactive dim")

local paint = require('paint')
map(map_prefix .. "paint", paint.create_paint, "Open paint window")
-- require('coffee').enable()


do
  local logpanel = require('velvet.diagnostics.logpanel')
  local function update_logpanel_state()
    if session.logpanel_enabled then
      logpanel.enable()
    else
      logpanel.disable()
    end
  end
  local function toggle_logpanel()
    session.logpanel_enabled = not session.logpanel_enabled
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

vv.options.theme = require('velvet.themes').catppuccin.mocha

-- I am too used to the position of these keys on MacOS
keymap.remap_key('§', '`')
keymap.remap_key('±', '~')

map("<F1>", require('velvet.extras.quake').toggle, "Toggle Quake window")

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
    for _, win in ipairs(velvet_window.get_window_at_coordinate(cord)) do
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

map("<C-x>v", function() 
  mouse_copy(function(text) 
    vv.api.clipboard_set(text)
  end)
end, { description = "Start copy mode" })

map("<C-x><space>", function()
  keymap.set_passthrough(true)
  local registration = { event = 'session.on_key', when = function(_, result) return result.data.key.name == 'ESCAPE' and result.data.key.event_type == 'press' end }
  -- triple tap escape to disable
  vv.async.run(function()
    local timeout = 200
    while keymap.get_passthrough() do
      vv.async.wait(registration)
      if vv.async.wait(registration, timeout) and vv.async.wait(registration, timeout) then
        keymap.set_passthrough(false)
        break
      end
    end
  end)
end, "Temporarily disable keymap")

map(map_prefix .. "<C-p>", function()
  local foc = vv.api.get_focused_window()
  if foc ~= 0 then
    vv.api.window_set_scroll_offset(foc, vv.api.window_get_scroll_offset(foc) + 3)
  end
end, { description = "scroll up", repeatable = true })

map(map_prefix .. "<C-n>", function()
  local foc = vv.api.get_focused_window()
  if foc ~= 0 then
    vv.api.window_set_scroll_offset(foc, vv.api.window_get_scroll_offset(foc) - 3)
  end
end, { description = "scroll down", repeatable = true })
map("<M-`>", dwm.select_previous_view, { description = "Select the previous view" })

vv.cli.add_command({
  name = "log-events",
  description = "<e1> {e2, e3, ...} -- keep logging the indicated events forever.",
  action = function(_, args)
    local inspect = function(...)
      local fmt = {...}
      return vv.inspect(#fmt == 1 and fmt[1] or fmt, { indent = '', newline = ' ' })
    end
    local params = {}
    local explicit = {}
    for i, arg in ipairs(args) do
      if i == 1 and arg == '--json' then
        local to_json = require('velvet.json').to_json
        inspect = function(...)
          local fmt = {...}
          return to_json(#fmt == 1 and fmt[1] or fmt)
        end
      else
        params[#params+1] = tonumber(arg) or arg
        explicit[arg] = true
      end
    end
    if #params == 0 then return ("No events specified.") end
    for _, result in vv.async.stream(table.unpack(params)) do
      -- normally window_output and pre_render are undesirable because they cause a render loop when printed,
      -- but we include them if they are explicitly added since it makes sense under some circumstances as
      -- long as the window does not output directly to a visible velvet window.
      if explicit[result.name] or (result.name ~= 'window.output' and result.name ~= 'pre_render') then
        print(type(result) == 'string' and result or inspect(result))
      end
    end
  end
})

-- workaround for ghostty not correctly setting associated text when option is held on MacOS
vv.async.run(function()
  local is_alt = function(k) return k.key.name == 'RIGHT_ALT' end
  local is_release = function(k) return k.key.event_type == 'release' end
  local is_press = function(k) return k.key.event_type == 'press' end

  local alt_down = { event = 'session.on_key', when = function(_, r) return is_alt(r.data) and is_press(r.data) end }
  local alt_up = { event = 'session.on_key', when = function(_, r) return is_alt(r.data) and is_release(r.data) end }

  local function send(payload)
    local foc = vv.api.get_focused_window()
    pcall(vv.api.window_send_keys, foc, payload)
  end

  local remap = {
    ["'"] = 'æ', ["z"] = 'æ', ["S-'"] = 'Æ', ["S-z"] = 'Æ',
    ["l"] = 'ø', ["o"] = 'ø', ["S-l"] = 'Ø', ["S-o"] = 'Ø',
    ["w"] = 'å', ["a"] = 'å', ["S-w"] = 'Å', ["S-a"] = 'Å',
  }

  local mappings = {}
  for from, to in pairs(remap) do
    mappings[string.format("<M-%s>", from)] = function() send(to) end
  end

  while true do
    vv.async.wait(alt_down)
    for from, to in pairs(mappings) do keymap.set(from, to) end
    vv.async.wait(alt_up)
    for from, _ in pairs(mappings) do keymap.del(from) end
  end
end)

require('clock')
-- require('multi_click')
