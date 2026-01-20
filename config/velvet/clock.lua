-- WIP: clocks and countdowns
local timer = require('velvet.window').create()
timer:set_geometry({ left = 1, top = 1, width = 106, height = 7 })
timer:set_opacity(0.4)
timer:set_cursor_visible(false)
timer:set_line_wrapping(true)
timer:set_frame_enabled(true)
timer:set_frame_color('blue')
timer:set_title('clock')
timer:set_transparency_mode('clear')

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

timer:set_background_color('red')

local index = 0
for _, chr in ipairs({ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', '.', '-' }) do
  for i, segments in ipairs(font[chr]) do
    timer:set_cursor(3 + 8 *index, i + 1)
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

