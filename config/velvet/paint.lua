local vv = require('velvet')
local paint = {}
local canvas = nil
function paint.create_paint()
  local sz = vv.api.get_screen_geometry()
  if canvas then canvas:close() end
  canvas = require('velvet.window').create()
  canvas:set_cursor_visible(false)

  local brush = {
    red = 0,
    green = 0,
    blue = 0,
  }
  local opacity = 1

  -- local width, height = sz.width - 20, sz.height - 10
  local width, height = sz.width // 3, sz.height
  canvas:set_geometry({ left = sz.width - width, top = 0, width = width, height = height })
  canvas:set_opacity(opacity)
  canvas:set_background_color('white')
  canvas:clear()
  canvas:set_background_color(brush)

  local function update_brush()
    canvas:set_background_color(brush)
  end

  --- @param x velvet.api.mouse.move.event_args | velvet.api.mouse.click.event_args
  local draw = function(win, x)
    if x.mouse_button == 'left' then
      win:set_cursor(x.pos.col, x.pos.row)
      win:draw(' ')
    end
  end

  canvas:on_mouse_click(draw)
  canvas:on_mouse_move(draw)

  local close_sequence = '<C-x>closepaint'
  vv.api.keymap_set(close_sequence, function()
    canvas:close()
    vv.api.keymap_del(close_sequence)
  end)

  do
    local pg = canvas:get_geometry()
    local wheel = canvas:create_child_window()
    local wheel_width, wheel_height = 37, 17
    local wg = { left = pg.left + pg.width - wheel_width - 1, top = pg.top + 1, width = wheel_width, height =
    wheel_height }
    wheel:set_geometry(wg)
    wheel:clear()
    wheel:set_opacity(0)
    wheel:set_transparency_mode('clear')
    wheel:set_cursor_visible(false)

    local cx = 1 + wg.width // 2
    local cy = 1 + wg.height // 2
    local sel_x, sel_y = cx, cy

    -- assume a pixel is twice as tall as it is wide

    local function hsv_to_rgb(h, s, v)
      local c = v * s
      -- float x = c * (1.0f - fabsf(fmodf(h / 60.0f, 2.0f) - 1.0f));
      local x = c * (1.0 - math.abs(((h / 60) % 2) - 1.0))
      local m = v - c
      local rp, gp, bp

      if h < 60 then
        rp, gp, bp = c, x, 0
      elseif h < 120 then
        rp, gp, bp = x, c, 0
      elseif h < 180 then
        rp, gp, bp = 0, c, x
      elseif h < 240 then
        rp, gp, bp = 0, x, c
      elseif h < 300 then
        rp, gp, bp = x, 0, c
      else
        rp, gp, bp = c, 0, x
      end

      local red = rp + m
      local green = gp + m
      local blue = bp + m

      return red, green, blue
    end

    local saturation = 1

    local sat_slider = wheel:create_child_window()
    sat_slider:set_geometry({ left = wg.left, width = wg.width, height = 1, top = wg.top + wg.height + 1 })
    sat_slider:clear()

    --- @return boolean,integer,integer,integer
    local function point_to_color(col, row)
      local px = col - cx
      local py = row - cy
      local normx = px / cx
      local normy = py / cy
      local dist = math.sqrt(normx * normx + normy * normy)
      if dist < 0.95 then
        local rad = math.atan(normy, normx) + math.pi
        local deg = (180 + rad * (180 / math.pi)) % 360
        local r, g, b = hsv_to_rgb(deg, dist, saturation)
        return true, r, g, b
      end
      return false, 0, 0, 0
    end

    local function highlight(r, g, b)
      local luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
      if luminance > 0.5 then return 0, 0, 0 else return 1, 1, 1 end
    end

    local function draw_saturation_slider()
      local sat = saturation
      for i = 1, wg.width do
        saturation = i / wg.width
        local ok, r, g, b = point_to_color(sel_x, sel_y)
        if ok then
          sat_slider:set_background_color({ red = r, green = g, blue = b })
          sat_slider:set_cursor(i, 1)
          if sat >= saturation and sat < ((i + 1) / wg.width) then
            local r2, g2, b2 = highlight(r, g, b)
            sat_slider:set_foreground_color({ red = r2, green = g2, blue = b2 })
            sat_slider:draw('◆')
          else
            sat_slider:draw(' ')
          end
        end
      end
      saturation = sat
    end

    local function draw_wheel()
      for row = 1, wg.height do
        for col = 1, wg.width do
          local ok, r, g, b = point_to_color(col, row)
          if ok then
            wheel:set_background_color({ red = r, green = g, blue = b, alpha = 0.05 })
            wheel:set_cursor(col, row)
            if row == sel_y and col == sel_x then
              local r2, g2, b2 = highlight(r, g, b)
              wheel:set_foreground_color({ red = r2, green = g2, blue = b2 })
              wheel:draw('◆')
            else
              wheel:draw(' ')
            end
          end
        end
      end
    end

    local function set_color(col, row)
      local ok, r, g, b = point_to_color(col, row)
      if ok then
        brush = { red = r, green = g, blue = b }
        update_brush()
        sel_x, sel_y = col, row
        draw_wheel()
        draw_saturation_slider()
      end
    end

    local function set_saturation(col)
      if col < 1 then col = 1 end if col > wg.width then col = wg.width end
      local sat = col / wg.width
      if saturation ~= sat then
        saturation = sat
        set_color(sel_x, sel_y)
      end
    end

    local sched_x, sched_y
    local function scheduled_wheel_update()
      if sched_x ~= sel_x or sched_y ~= sel_y then
        set_color(sched_x, sched_y)
      end
    end

    --- @type velvet.window|nil
    local drag_win = nil
    --- @param x velvet.api.mouse.move.event_args | velvet.api.mouse.click.event_args
    local function mouse_pick_hue(w, x)
      if x.mouse_button == 'left' then
        local ok = point_to_color(x.pos.col, x.pos.row)
        if x.event_type and x.event_type == 'mouse_down' then
          drag_win = ok and wheel or canvas
        elseif x.event_type and x.event_type == 'mouse_up' then
          drag_win = nil
        end
        if drag_win == nil or drag_win == wheel then
          sched_x, sched_y = x.pos.col, x.pos.row
          vv.api.schedule_after(0, scheduled_wheel_update)
        else
          local gcol, grow = x.pos.col + wg.left, x.pos.row + wg.top
          local lcol, lrow = gcol - pg.left, grow - pg.top
          x.pos = { col = lcol, row = lrow }
          draw(canvas, x)
        end
      end
    end
    wheel:on_mouse_click(mouse_pick_hue)
    wheel:on_mouse_move(mouse_pick_hue)

    local sched_sat = -1
    local function scheduled_saturation_update()
      set_saturation(sched_sat)
    end

    local function mouse_pick_saturation(_, x)
      if x.mouse_button == 'left' then
        sched_sat = x.pos.col
        vv.api.schedule_after(0, scheduled_saturation_update)
      end
    end
    sat_slider:on_mouse_click(mouse_pick_saturation)
    sat_slider:on_mouse_move(mouse_pick_saturation)
    sat_slider:set_cursor_visible(false)

    set_color(sel_x, sel_y)
    set_saturation(wg.width)

    -- local fps_target = 30
    -- local sat = 0
    -- local function cycle_saturation()
    --   local start = vv.api.get_current_tick()
    --   sat = (sat + 0.01) % 2
    --   saturation = (math.abs((sat / 2) - 0.5) + 0.1) * 1.6
    --   set_color(sel_x, sel_y)
    --   vv.api.schedule_after(1000 // fps_target, cycle_saturation)
    --   local now = vv.api.get_current_tick()
    --   dbg({set_color = now - start})
    -- end
    -- cycle_saturation()
    -- canvas:set_visibility(false)
  end
end

return paint
