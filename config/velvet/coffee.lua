local vv = require('velvet')

-- Found at https://emojicombos.com/coffee-ascii-art
local coffee_frames = { [[
                  ⢀
                  ⡼
                 ⣼⠇
                ⠰⡏
                ⢰⡇
                ⢸⣷⡀
                 ⢿⣷⡀
               ⢀ ⠈⢻⣿⣄
               ⠈⢆  ⠙⣿⣆
                 ⢧  ⠘⢿⣇
                 ⣸⡆  ⠘⣿⡀
                ⣰⣿⠃   ⣿⠇
               ⣼⣿⠃    ⡿⠁
               ⣿⡏⣀⣀⣀ ⡜
       ⣀⡤⠤⠒⠒⠋⠉⠉⠻⣧   ⠈⠉⠁   ⠢⢄
      ⣾⣿    ⣀⣀⣀⣀⣤⣽⣦⣄⣀⣀⣀⣀    ⢹
      ⣿⣿⣿⠷⠾⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠶⠚
      ⢿⣿⡏      ⠈⠉⠉⠉⠉⠉⠉       ⣸⠛⠻⣷
      ⠸⣿⣧                   ⢀⠃ ⢠⣿⠇
       ⣹⣿⡆                 ⢠⣎⣠⣴⠿⠃
 ⢀⣠⠔⠒⠈⠉ ⠹⣿⣄               ⣠⠾⠛⠛⠉⠒⠢⣄
 ⣿⡁      ⠈⢻⣦⡀           ⣀⣾⡃       ⡟
 ⠙⠻⣶⣀      ⠈⠙⠲⠦⣤⣄⣀⣀⣀⣤⣤⣾⣯⡵⠞⠋   ⣀⠟
    ⠉⠛⠻⠿⠿⠶⠶⠤⠤⠤⣄⣀⣀⣀⣀⣀⣀⣀⣀⡠⠤⠤⠤⠴⠖⠉
]], [[
                   ⢀
                   ⡼
                  ⣼⠇
                 ⠰⡏
                 ⢰⡇
                 ⢸⣷⡀
                  ⢿⣷⡀
                ⢀ ⠈⢻⣿⣄
                ⠈⢆  ⠙⣿⣆
                  ⢧  ⠘⢿⣇
                  ⣸⡆  ⠘⣿⡀
                 ⣰⣿⠃   ⣿⠇
                ⣼⣿⠃    ⡿⠁
                ⣿⡏⣀⣀  ⡜
       ⣀⡤⠤⠒⠒⠋⠉⠉⠉⠻⣧  ⠈⠉⠁   ⠢⢄
      ⣾⣿    ⣀⣀⣀⣀⣤⣽⣦⣄⣀⣀⣀⣀    ⢹
      ⣿⣿⣿⠷⠾⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠶⠚
      ⢿⣿⡏      ⠈⠉⠉⠉⠉⠉⠉       ⣸⠛⠻⣷
      ⠸⣿⣧                   ⢀⠃ ⢠⣿⠇
       ⣹⣿⡆                 ⢠⣎⣠⣴⠿⠃
 ⢀⣠⠔⠒⠈⠉ ⠹⣿⣄               ⣠⠾⠛⠛⠉⠒⠢⣄
 ⣿⡁      ⠈⢻⣦⡀           ⣀⣾⡃       ⡟
 ⠙⠻⣶⣀      ⠈⠙⠲⠦⣤⣄⣀⣀⣀⣤⣤⣾⣯⡵⠞⠋   ⣀⠟
    ⠉⠛⠻⠿⠿⠶⠶⠤⠤⠤⣄⣀⣀⣀⣀⣀⣀⣀⣀⡠⠤⠤⠤⠴⠖⠉
]] }
local frame_order = { 2, 1 }

-- some small number which most likely doesn't cover any windows
local bg = require('velvet.window').create()
bg:set_z_index(vv.layers.background)
bg:set_opacity(0)
bg:set_transparency_mode(vv.api.transparency_mode.all)
bg:set_line_wrapping(false)
bg:set_cursor_visible(false)
local colors = { 'red', 'green', 'blue', 'white', 'magenta', 'yellow' }
local color = 1
local frame = 1

local function draw_coffee()
  frame = 1 + (frame % #frame_order)
  local coffee = coffee_frames[frame_order[frame]]
  local sz = vv.api.get_screen_geometry()
  bg:set_geometry({ left = 0, top = 0, width = sz.width, height = sz.height })

  bg:clear_background_color()
  bg:set_foreground_color(colors[color])
  bg:clear()
  local width = 0
  local height = 0
  for line in coffee:gmatch('(.-)\n') do
    local strwidth = utf8.len(line) or 0
    if strwidth > width then width = strwidth end
    height = height + 1
  end

  local lnum = 0
  local col = (sz.width // 2) - (width // 2)
  local row = sz.height // 2 - height // 2
  if col < 0 then col = 0 end
  if row < 0 then row = 0 end
  for line in coffee:gmatch('(.-)\n') do
    bg:set_cursor(col, row + lnum)
    bg:draw(line)
    lnum = lnum + 1
    if lnum >= sz.height then break end
  end
end

do
  bg:on_mouse_click(function(_, args)
    if args.mouse_button == vv.api.mouse_button.left and args.event_type == vv.api.mouse_event_type.mouse_down then
      color = 1 + (color % #colors)
      draw_coffee()
    end
  end)
end

return {
  enable = function()
    draw_coffee()
    require('velvet.events').create_group('coffee_redraw', true).screen_resized = draw_coffee
    local coffee_animation_schedule = nil
    coffee_animation_schedule = function()
      if bg:valid() then
        draw_coffee()
        vv.api.schedule_after(1500, coffee_animation_schedule)
      end
    end
    coffee_animation_schedule()
  end,
  disable = function()
  end
}

