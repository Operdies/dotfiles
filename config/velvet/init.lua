local vv = require('velvet')
local default_shell = os.getenv("SHELL") or "bash"
local o = vv.options
local home = os.getenv("HOME"):gsub("/$", "")
local map = vv.api.keymap_set
local rmap = function(keys, action) vv.api.keymap_set(keys, action, { repeatable = true }) end

local function num_to_tags(num)
  return 1 << (num - 1)
end

local prev_view = 1
local function set_view(view)
  if type(view) == 'number' then
    view = { view }
  end
  local bits = 0
  for _, num in ipairs(view) do
    bits = bits | num_to_tags(num)
  end
  prev_view = o.view
  vv.api.set_view(bits)
end

local function enable_view(num)
  local bits = num_to_tags(num)
  prev_view = o.view
  o.view = o.view | bits
end

local function restore_view()
  local current = o.view
  vv.api.set_view(prev_view)
  prev_view = current
end

local function set_tags(tags)
  if type(tags) == 'number' then
    tags = { tags }
  end
  local bits = 0
  for _, num in ipairs(tags) do
    bits = bits | num_to_tags(num)
  end
  vv.api.window_set_tags(vv.api.get_focused_window(), bits)
end

local function toggle_view(num)
  local view = o.view
  prev_view = view
  view = view ~ num_to_tags(num)
  o.view = view
end

local function toggle_tag(num)
  local tags = vv.api.window_get_tags(vv.api.get_focused_window())
  tags = tags ~ num_to_tags(num)
  vv.api.window_set_tags(0, tags)
end

local function spawn(cmd) return vv.api.window_create_process(cmd) end

rmap("<C-x>b", function() spawn("bash") end)
map("<C-x>c", function() vv.api.window_create_process(default_shell) end)
map("<C-x>d", function() vv.api.session_detach(vv.api.get_active_session()) end)
map("<C-x>K", function() vv.api.window_close(vv.api.get_focused_window()) end)
map("<C-x>r", function() dofile(home .. "/.config/velvet/init.lua") end)

rmap("<C-x>j", function() spawn("bash") end)

for i = 1, 9 do
  map(("<C-x>%d"):format(i), function() toggle_tag(i) end)
  map(("<C-x><M-%d>"):format(i), function() toggle_view(i) end)
  map(("<M-%d>"):format(i), function() set_view(i) end)
  map(("<M-S-%d>"):format(i), function() set_tags(i) end)
end
map("<M-0>", function() set_view({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }) end)
map("<S-M-0>", function() set_tags({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }) end)


map("<M-`>", restore_view)

local function resize_focus(x, y)
  local id = vv.api.get_focused_window()
  if id then
    local geom = vv.api.window_get_geometry(id)
    if geom then
      geom.width = geom.width + x
      geom.height = geom.height + y
      vv.api.window_set_geometry(id, geom)
    end
  end
end

local function move_focus(x, y)
  local id = vv.api.get_focused_window()
  if id then
    local geom = vv.api.window_get_geometry(id)
    if geom then
      geom.left = geom.left + x
      geom.top = geom.top + y
      vv.api.window_set_geometry(id, geom)
    end
  end
end

map("<M-S-left>", function()
  resize_focus(-1, 0)
end)

map("<M-S-right>", function()
  resize_focus(1, 0)
end)

map("<M-S-up>", function()
  resize_focus(0, -1)
end)

map("<M-S-down>", function()
  resize_focus(0, 1)
end)

map("<M-left>", function()
  move_focus(-1, 0)
end)

map("<M-right>", function()
  move_focus(1, 0)
end)

map("<M-up>", function()
  move_focus(0, -1)
end)

map("<M-down>", function()
  move_focus(0, 1)
end)

map("<C-x>t", function() vv.api.window_set_layer(vv.api.get_focused_window(), "tiled") end)
map("<C-x>f", function() vv.api.window_set_layer(vv.api.get_focused_window(), "floating") end)
map("<C-x><C-x>", function() vv.api.window_send_keys(vv.api.get_focused_window(), "<C-x>") end)

local function round(x)
  if x >= 0 then
    return math.floor(x + 0.5)
  else
    return math.ceil(x - 0.5)
  end
end

local easing = {
  overshoot = function(t)
    local s = 1.70158
    return 1 + (((t - 1) * (t - 1)) * ((s + 1) * (t - 1) + s))
  end,
  linear = function(t) return t end,
  spring = function(t)
    local w = 8
    local x = 1.0 - (1.0 + w * t) * math.exp(-w * t)
    local norm = 1.0 - (1.0 + w) * math.exp(-w)
    return x / norm
  end,
}

local animating = {}
local function animate(id, target, duration, opts)
  if animating[id] then return end
  animating[id] = true

  local start_time = vv.api.get_current_tick()
  local geom = vv.api.window_get_geometry(id)
  local delta_x = target.left - geom.left
  local delta_y = target.top - geom.top
  local delta_w = target.width - geom.width
  local delta_h = target.height - geom.height

  local ease = opts.easing_function or easing.linear

  local f = function() end
  f = function()
    if not vv.api.window_is_valid(id) then
      animating[id] = nil
      return
    end
    local elapsed = vv.api.get_current_tick() - start_time
    if elapsed >= duration then
      animating[id] = nil
      vv.api.window_set_geometry(id, target)
      if opts.done then opts.done() end
      return
    end
    local pct = ease(elapsed / duration)
    local frame_geom = {
      left = round(geom.left + delta_x * pct),
      top = round(geom.top + delta_y * pct),
      width = round(geom.width + delta_w * pct),
      height = round(geom.height + delta_h * pct),
    }
    vv.api.window_set_geometry(id, frame_geom)
    vv.api.schedule_after(5, f)
  end
  f()
end

local function window_visible(id)
  return (vv.api.window_get_tags(id) & o.view) > 0
end

local function window_tiled(id)
  return vv.api.window_get_layer(id) == "tiled"
end

local function get_prev_matching(id, match)
  local windows = vv.api.get_windows()
  local pivot = -1
  for i, win in ipairs(windows) do
    if win == id then
      pivot = i - 1
      break
    end
  end
  for i=#windows-1,0,-1 do
    local index = 1 + ((i + pivot) % (#windows))
    if match(windows[index]) then return windows[index] end
  end
  return nil
end

local function get_first_matching(match)
  local windows = vv.api.get_windows()
  for _, id in ipairs(windows) do 
    if match(id) then return id end
  end
  return nil
end

local function get_next_matching(id, match)
  local windows = vv.api.get_windows()
  local pivot = -1
  for i, win in ipairs(windows) do
    if win == id then
      pivot = i - 1
      break
    end
  end
  for i=1,#windows do
    local index = 1 + ((i + pivot) % (#windows))
    if match(windows[index]) then return windows[index] end
  end
  return nil
end

local function focus_next()
  local current = vv.api.get_focused_window()
  local next = get_next_matching(current, window_visible)
  if next then vv.api.set_focused_window(next) end
end

local function focus_prev()
  local current = vv.api.get_focused_window()
  local prev = get_prev_matching(current, window_visible)
  if prev then vv.api.set_focused_window(prev) end
end

local function swap(a, b)
  if animating[a] or animating[b] then return end
  if a and b and a ~= b then
    local l1 = vv.api.window_get_layer(a)
    local l2 = vv.api.window_get_layer(b)
    local g1 = vv.api.window_get_geometry(a)
    local g2 = vv.api.window_get_geometry(b)

    local i = 2
    -- only set window layers after both windows were fully moved
    local done = function()
      i = i - 1
      if i == 0 then
        vv.api.window_set_layer(a, l2)
        vv.api.window_set_layer(b, l1)
      end
    end
    animate(a, g2, 200, { easing_function = easing.spring, done = done })
    animate(b, g1, 200, { easing_function = easing.spring, done = done })
    vv.api.swap_windows(a, b)
  end
end

local function swap_prev()
  local current = vv.api.get_focused_window()
  local prev = get_prev_matching(current, function(w) return window_visible(w) end)
  swap(current, prev)
end

local function swap_next()
  local current = vv.api.get_focused_window()
  local next = get_next_matching(current, function(w) return window_visible(w) end)
  swap(current, next)
end

local function zoom()
  local current = vv.api.get_focused_window()
  local next = get_first_matching(function(w)
    return window_visible(w) and window_tiled(w) and w ~= current
  end)
  swap(current, next)
  local first_tiled = get_first_matching(function(w) return w == current or w == next end)
  if first_tiled then
    vv.api.set_focused_window(first_tiled)
  end
end

rmap("<C-x><C-j>", focus_next)
rmap("<C-x><C-k>", focus_prev)
rmap("<C-x>j", swap_next)
rmap("<C-x>k", swap_prev)
rmap("<C-x>g", zoom)

o.display_damage = false
o.focus_follows_mouse = true

local function translate(geom, x, y)
  local new_geom = { width = geom.width, height = geom.height, left = geom.left + round(x), top = geom.top + round(y) }
  return new_geom
end
local function scale(geom, x, y)
  local new_geom = { width = round(geom.width * x), height = round(geom.height * y), left = geom.left, top = geom.top }
  return new_geom
end

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

local function set_geom_as_title(id)
  local geom = vv.api.window_get_geometry(id)
  -- vv.api.window_set_title(id, ("%dx%d+%d+%d"):format(geom.width, geom.height, geom.left, geom.top))
end

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
    local tags = num_to_tags(9)
    vv.api.window_set_tags(id, tags)
    enable_view(9)
  end
end)


-- vv.subscribe(vv.events.window.created, function(id)
--   vv.api.window_set_layer(id, "floating")
--   local geom = { width = 100, height = 7, left = 9, top = 3 }
--   vv.api.window_set_geometry(id, geom)
-- end)
