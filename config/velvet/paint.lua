local vv = require('velvet')
local paint = {}
local cool_win = nil
function paint.create_paint()
  local sz = vv.api.get_screen_geometry()
  if cool_win then cool_win:close() end
  cool_win = require('velvet.window').create()
  cool_win:set_cursor_visible(false)

  local brush = {
    red = 0,
    green = 0,
    blue = 0,
  }
  local opacity = 1

  -- local width, height = sz.width - 20, sz.height - 10
  local width, height = sz.width // 3, sz.height
  cool_win:set_geometry({ left = sz.width - width, top = 0, width = width, height = height })
  cool_win:set_opacity(opacity)
  cool_win:set_background_color('white')
  cool_win:clear()
  cool_win:set_background_color(brush)

  local function update_brush()
    cool_win:set_background_color(brush)
  end

  do
    --- @param x velvet.api.mouse.move.event_args | velvet.api.mouse.click.event_args
    local draw = function(win, x)
      if x.mouse_button == vv.api.mouse_button.left then
        win:set_cursor(x.pos.col, x.pos.row)
        win:draw(' ')
      end
    end

    cool_win:on_mouse_click(draw)
    cool_win:on_mouse_move(draw)
  end

  local close_sequence = '<C-x>closepaint'
  vv.api.keymap_set(close_sequence, function()
    cool_win:close()
    vv.api.keymap_del(close_sequence)
  end)

  do
    local pg = cool_win:get_geometry()
    local wheel = cool_win:create_child_window()
    local wheel_width, wheel_height = 37, 17
    local wg = { left = pg.left + pg.width - wheel_width - 1, top = pg.top + 1, width = wheel_width, height =
    wheel_height }
    wheel:set_geometry(wg)
    wheel:clear()
    wheel:set_opacity(0)
    wheel:set_transparency_mode('clear')

    local cx = 1 + wg.width // 2
    local cy = 1 + wg.height // 2
    local sel_x, sel_y = cx, cy

    -- assume a pixel is twice as tall as it is wide

    local function round(x)
      if x >= 0 then
        return math.floor(x + 0.5)
      else
        return math.ceil(x - 0.5)
      end
    end


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

      local mult = 255
      local red = round((rp + m) * mult)
      local green = round((gp + m) * mult)
      local blue = round((bp + m) * mult)

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

    local function draw_saturation_slider()
      local sat = saturation
      local step = 1 / wg.width
      for i = 1, wg.width do
        saturation = i / wg.width
        local ok, r, g, b = point_to_color(sel_x, sel_y)
        if ok then
          sat_slider:set_background_color({ red = r, green = g, blue = b })
          sat_slider:set_cursor(i, 1)
          if saturation >= sat and saturation < (sat + step) then
            local r2, g2, b2 = 255 - r, 255 - g, 255 - b
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
      for row = 0, wg.height do
        for col = 0, wg.width do
          local ok, r, g, b = point_to_color(col, row)
          if ok then
            wheel:set_background_color({ red = r, green = g, blue = b })
            wheel:set_cursor(col, row)
            if row == sel_y and col == sel_x then
              local r2, g2, b2 = 255 - r, 255 - g, 255 - b
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
      saturation = col / wg.width
      set_color(sel_x, sel_y)
    end


    --- @param x velvet.api.mouse.move.event_args | velvet.api.mouse.click.event_args
    local function mouse_pick_hue(_, x)
      if x.mouse_button == vv.api.mouse_button.left then
        if x.pos.col ~= sel_x or x.pos.row ~= sel_y then
          set_color(x.pos.col, x.pos.row)
        end
      end
    end
    wheel:on_mouse_click(mouse_pick_hue)
    wheel:on_mouse_move(mouse_pick_hue)

    local function mouse_pick_saturation(_, x)
      if x.mouse_button == vv.api.mouse_button.left then
        set_saturation(x.pos.col)
      end
    end
    sat_slider:on_mouse_click(mouse_pick_saturation)
    sat_slider:on_mouse_move(mouse_pick_saturation)

    set_color(sel_x, sel_y)
    set_saturation(wg.width)

    -- local function cycle_saturation()
    --   local start = vv.api.get_current_tick()
    --   saturation = (saturation + 0.1) % 1
    --   set_color(sel_x, sel_y)
    --   vv.api.schedule_after(1000 // 10, cycle_saturation)
    --   local now = vv.api.get_current_tick()
    --   dbg({set_color = now - start})
    -- end
    -- cycle_saturation()
  end
end

return paint
