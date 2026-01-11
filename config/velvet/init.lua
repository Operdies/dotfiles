local vv = require('velvet')
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
  vv.api.set_tags(bits, 0)
end

local function toggle_view(num)
  local view = o.view
  prev_view = view
  view = view ~ num_to_tags(num)
  o.view = view
end

local function toggle_tag(num)
  local tags = vv.api.get_tags(0)
  tags = tags ~ num_to_tags(num)
  vv.api.set_tags(tags, 0)
end


map("<C-x>c", function() vv.api.spawn("zsh") end)
map("<C-x>d", vv.api.detach)
map("<C-x>K", vv.api.close_window)
map("<C-x>r", function() dofile(home .. "/.config/velvet/init.lua") end)

rmap("<C-x>j", function() vv.api.spawn("bash") end)

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
    local geom = vv.api.get_window_geometry(id)
    if geom then
      geom.width = geom.width + x
      geom.height = geom.height + y
      vv.api.set_window_geometry(id, geom)
    end
  end
end

local function move_focus(x, y)
  local id = vv.api.get_focused_window()
  if id then
    local geom = vv.api.get_window_geometry(id)
    if geom then
      geom.left = geom.left + x
      geom.top = geom.top + y
      vv.api.set_window_geometry(id, geom)
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

map("<C-x>t", function() vv.api.set_layer(vv.api.get_focused_window(), "tiled") end)
map("<C-x>f", function() vv.api.set_layer(vv.api.get_focused_window(), "floating") end)
map("<C-x><C-x>", function() vv.api.window_send_keys(vv.api.get_focused_window(), "<C-x>") end)

local function window_visible(id)
  return (vv.api.get_tags(id) & o.view) > 0
end

local function window_tiled(id)
  return vv.api.get_layer(id) == "tiled"
end

local function get_prev_matching(id, match)
  local windows = vv.api.list_windows()
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
  local windows = vv.api.list_windows()
  for _, id in ipairs(windows) do 
    if match(id) then return id end
  end
  return nil
end

local function get_next_matching(id, match)
  local windows = vv.api.list_windows()
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
  if a and b and a ~= b then 
    vv.api.swap_windows(a, b)
  end
end

local function swap_prev()
  local current = vv.api.get_focused_window()
  local prev = get_prev_matching(current, function(w) return window_visible(w) and window_tiled(w) end)
  swap(current, prev)
end

local function swap_next()
  local current = vv.api.get_focused_window()
  local next = get_next_matching(current, function(w) return window_visible(w) and window_tiled(w) end)
  swap(current, next)
end

local function zoom()
  local current = vv.api.get_focused_window()
  local next = get_first_matching(function(w)
    return window_visible(w) and window_tiled(w) and w ~= current
  end)
  swap(current, next)
  local first_tiled = get_first_matching(function(w) return window_visible(w) and window_tiled(w) end)
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

