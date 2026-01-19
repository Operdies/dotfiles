local vv = require('velvet')
local paint = {}
local cool_win = nil
function paint.create_paint()
  local sz = vv.api.get_screen_geometry()
  if cool_win then cool_win:close() end
  cool_win = require('velvet.window').create()

  local brush = {
    red = 0,
    green = 0,
    blue = 0,
  }
  local opacity = 1

  local width, height = 30, 12
  cool_win:set_geometry({ left = sz.width - width - 15, top = 2, width = width, height = height })
  cool_win:set_opacity(opacity)
  cool_win:set_background_color('white')
  cool_win:clear()
  cool_win:set_background_color(brush)

  local function update_brush()
    cool_win:set_cursor(1, 1)
    cool_win:set_background_color(brush)
    cool_win:draw('brush')
  end

  cool_win:on_mouse_scroll(function(win, scroll)
    if scroll.direction == vv.api.scroll_direction.down then
      brush.red = (brush.red + 5) % 255
    elseif scroll.direction == vv.api.scroll_direction.up then
      brush.red = (brush.red - 5) % 255
    elseif scroll.direction == vv.api.scroll_direction.left then
      brush.green = (brush.green + 5) % 255
    elseif scroll.direction == vv.api.scroll_direction.right then
      brush.green = (brush.green - 5) % 255
    end

    local geom = win:get_geometry()
    update_brush()
  end)

  do
    local dragging = false
    cool_win:on_mouse_click(function(win, click)
      if click.mouse_button == vv.api.mouse_button.left then
        dragging = click.event_type == vv.api.mouse_event_type.mouse_down
      end
    end)

    cool_win:on_mouse_move(function(win, move)
      if dragging then
        win:set_cursor(move.pos.col, move.pos.row)
        win:draw(' ')
      end
    end)
  end

  local close_sequence = '<C-x>closepaint'
  vv.api.keymap_set(close_sequence, function()
    cool_win:close()
    vv.api.keymap_del(close_sequence)
  end)

  local function index_to_color(i)
    local geom = cool_win:get_geometry()
    return math.floor(i * (255 / geom.height))
  end

  local function slider_update(slider, color, selected)
    local geom = cool_win:get_geometry()
    for i = 1, geom.height do
      slider:set_cursor(1, i)
      local bg = { red = 0, green = 0, blue = 0 }
      bg[color] = index_to_color(i)
      slider:set_background_color(bg)
      if i == selected then
        slider:draw(' ◇ ')
      else
        slider:draw('   ')
      end
    end
  end

  --- @return velvet.window
  local function create_slider(color, offset)
    local geom = cool_win:get_geometry()
    local slider = cool_win:create_child_window()
    slider:set_geometry({
      left = geom.left + geom.width + offset,
      width = 3,
      height = geom.height,
      top = geom.top,
    })

    slider_update(slider, color, 1)
    return slider
  end

  local red_slider = create_slider('red', 0)
  local green_slider = create_slider('green', 3)
  local blue_slider = create_slider('blue', 6)

  local sliders = {
    red = red_slider,
    green = green_slider,
    blue = blue_slider
  }

  for scol, slider in pairs(sliders) do
    local function set_color_index(i)
      brush[scol] = index_to_color(i)
      slider_update(slider, scol, i)
      update_brush()
    end
    slider:on_mouse_click(function(_, args)
      if args.mouse_button == vv.api.mouse_button.left then
        set_color_index(args.pos.row)
      end
    end)
    slider:on_mouse_move(function(_, args)
      if args.mouse_button == vv.api.mouse_button.left then
        set_color_index(args.pos.row)
      end
    end)
  end
end

return paint
