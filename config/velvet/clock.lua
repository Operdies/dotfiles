-- WIP: clocks and countdowns
local vv = require('velvet')
local timer = require('velvet.window').create()

-- brick font stolen from: https://github.com/race604/clock-tui/blob/master/clock-tui/src/clock_text/font/bricks.rs
local font = {
  ["0"] = { { 0, 6 }, { 0, 2, 2, 2 }, { 0, 2, 2, 2 }, { 0, 2, 2, 2 }, { 0, 6 } },
  ["1"] = { { 0, 4 }, { 2, 2 }, { 2, 2 }, { 2, 2 }, { 0, 6 } },
  ["2"] = { { 0, 6 }, { 4, 2 }, { 0, 6 }, { 0, 2 }, { 0, 6 } },
  ["3"] = { { 0, 6 }, { 4, 2 }, { 0, 6 }, { 4, 2 }, { 0, 6 } },
  ["4"] = { { 0, 2, 2, 2 }, { 0, 2, 2, 2 }, { 0, 6 }, { 4, 2 }, { 4, 2 } },
  ["5"] = { { 0, 6 }, { 0, 2 }, { 0, 6 }, { 4, 2 }, { 0, 6 } },
  ["6"] = { { 0, 6 }, { 0, 2 }, { 0, 6 }, { 0, 2, 2, 2 }, { 0, 6 } },
  ["7"] = { { 0, 6 }, { 4, 2 }, { 4, 2 }, { 4, 2 }, { 4, 2 } },
  ["8"] = { { 0, 6 }, { 0, 2, 2, 2 }, { 0, 6 }, { 0, 2, 2, 2 }, { 0, 6 } },
  ["9"] = { { 0, 6 }, { 0, 2, 2, 2 }, { 0, 6 }, { 4, 2 }, { 0, 6 } },
  [":"] = { {}, { 2, 2 }, {}, { 2, 2 }, {} },
  ["."] = { {}, {}, {}, {}, { 2, 2 } },
  ["-"] = { {}, {}, { 0, 6 }, {}, {} },
}

local function update_clock()
  local text = os.date('%H:%M')
  --- @cast text string
  local width = #text * 8
  local height = 7
  local sz = vv.api.get_screen_geometry()
  timer:set_geometry({ left = sz.width // 2 - width // 2 - 1, top = sz.height - height - 5, width = width + 1, height = height })

  timer:clear_background_color()
  timer:clear()
  timer:set_opacity(0)
  timer:set_transparency_mode('clear')
  timer:set_background_color('red')
  timer:set_z_index(vv.layers.background + 1)
  timer:set_cursor_visible(false)
  local index = 0
  for chr in text:gmatch('.') do
    for i, segments in ipairs(font[chr]) do
      timer:set_cursor(3 + 8 * index, i + 1)
      for x, len in ipairs(segments) do
        if x % 2 == 0 then
          local draw = string.rep(' ', len)
          timer:draw(draw)
        elseif len > 0 then
          timer:draw(('\x1b[%dC'):format(len))
        end
      end
    end
    index = index + 1
  end
end

local function clock_timer()
  if not timer:valid() then return end
  update_clock()
  local seconds = tonumber(os.date('%S'))
  local sleep_ms = (60 - seconds) * 1000
  vv.api.schedule_after(sleep_ms, clock_timer)
end
clock_timer()

require('velvet.events').create_group('my_clock', true).screen_resized = update_clock
