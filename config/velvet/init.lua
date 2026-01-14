local vv = require('velvet')
require('velvet.default_config')

local home = os.getenv("HOME"):gsub("/$", "")
local map = vv.api.keymap_set
local rmap = function(keys, action) vv.api.keymap_set(keys, action, { repeatable = true }) end
local function spawn(cmd) return vv.api.window_create_process(cmd) end

rmap("<C-x>b", function() spawn("bash") end)
map("<C-x>K", function() vv.api.window_close(vv.api.get_focused_window()) end)

map("<C-x>r", function() 
  package.loaded['velvet.default_config'] = nil
  package.loaded['velvet.events'] = nil
  vv.events = require('velvet.events')
  dofile(home .. "/.config/velvet/init.lua") 
end)

local function round(x)
  if x >= 0 then
    return math.floor(x + 0.5)
  else
    return math.ceil(x - 0.5)
  end
end


local function translate(geom, x, y)
  local new_geom = { width = geom.width, height = geom.height, left = geom.left + round(x), top = geom.top + round(y) }
  return new_geom
end
local function scale(geom, x, y)
  local new_geom = { width = round(geom.width * x), height = round(geom.height * y), left = geom.left, top = geom.top }
  return new_geom
end

local anim = require('velvet.stdlib.animation')
local easing = anim.easing
local animate = anim.animate

local function juggle(duration)
  local geom = vv.api.get_terminal_geometry()
  local function func(win, initial_geometry, restore)
    animate(win, { width = round(geom.width * 0.3), height = round(geom.height * 0.3), left = 10, top = 10 }, duration, {
      easing_function = easing.overshoot,
      done = function()
        animate(win, translate(vv.api.window_get_geometry(win), geom.width * 0.5, 0), duration, {
          easing_function = easing.spring,
          done = function()
            animate(win, scale(vv.api.window_get_geometry(win), 3, 3), duration, {
              easing_function = easing.overshoot,
              done = function()
                animate(win,
                  translate(scale(vv.api.window_get_geometry(win), 0.7, 0.7), -geom.width * 0.3, -geom.height * 0.3),
                  duration, {
                  easing_function = easing.linear,
                  done = function()
                    animate(win, initial_geometry, duration, {
                      easing_function = easing.spring,
                      done = function()
                        if restore then restore() end
                      end
                    })
                  end
                })
              end
            })
          end
        })
      end
    })
  end

  local windows = vv.api.get_windows()
  local delay = 0
  for _, id in ipairs(windows) do
    local initial_geom = vv.api.window_get_geometry(id)
    local initial_layer = vv.api.window_get_layer(id)
    vv.api.schedule_after(delay, function()
      func(id, initial_geom, function()
        vv.api.window_set_geometry(id, initial_geom)
        vv.api.window_set_layer(id, initial_layer)
      end)
    end)
    delay = delay + 200
  end
end

vv.api.keymap_set("<C-x>ffff", function() juggle(1700) end)
vv.options.key_repeat_timeout = 500

local grp = vv.events.create_group("stuff", true)
local ev = vv.events
-- ev.subscribe(grp, ev.window.moved, set_geom_as_title)
-- ev.subscribe(grp, ev.window.resized, set_geom_as_title)
ev.subscribe(grp, ev.screen.resized, function() 
  local geom = vv.api.get_terminal_geometry()
  print(vv.inspect({ screen_size = geom }))
end)

ev.subscribe(grp, ev.window.created, function(id) 
  local title = vv.api.window_get_title(id)
  if title == 'DAP External Terminal' then 
    local tags = 1 << 8
    vv.api.window_set_tags(id, tags)
  end
end)

map("<M-right>", function() 
  local win = vv.api.get_focused_window()
  local geom = translate(vv.api.window_get_geometry(win), 100, 0)
  animate(win, geom, 250, { easing_function = anim.easing.spring })
end)

map("<M-left>", function() 
  local win = vv.api.get_focused_window()
  local geom = translate(vv.api.window_get_geometry(win), -100, 0)
  animate(win, geom, 250, { easing_function = anim.easing.spring })
end)
