local map_prefix = "<C-x>"
require('velvet.presets.dwm').setup({ prefix = map_prefix, startup = { spawn_shell = true }, shutdown = { on_last_window_exit = true }})

-- values stored in |storage| will survive reloads.
local storage = require('velvet.runtime_storage').create("config")

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
    if storage.logpanel_enabled then
      logpanel.enable()
    else
      logpanel.disable()
    end
  end
  local function toggle_logpanel()
    storage.logpanel_enabled = not storage.logpanel_enabled
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

local mouse_select = require('mouse_select')
map("<C-x>v", mouse_select.select_and_copy, { description = "Start copy mode" })

map("<C-x><space>", function()
  keymap.set_passthrough(true)
  local registration = { event = 'on_key', when = function(_, result) return result.data.key.name == 'ESCAPE' and result.data.key.event_type == 'press' end }
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
  description = "print the indicated events as json",
  complete = function(...) 
    local seen = {}
    for _, v in ipairs({...}) do
      seen[v] = true
    end
    local events = vv.async.get_observed_events()
    local completions = {{name = "--json", description = "format the output as json" }}
    for k, v in pairs(events) do
      if not seen[k] then
        completions[#completions+1] = { name = k, description = type(v) == 'string' and v or nil }
      end
    end
    return completions
  end,
  action = function(_, ...)
    local to_json = require('velvet.json').to_json
    local inspect = function(...)
      local fmt = {...}
      return to_json(#fmt == 1 and fmt[1] or fmt)
    end
    local params = {}
    local explicit = {}
    for _, arg in ipairs({...}) do
      params[#params+1] = tonumber(arg) or arg
      explicit[arg] = true
    end
    if #params == 0 then return ("No events specified.") end
    for _, result in vv.async.stream(table.unpack(params)) do
      -- normally window_output and pre_render are undesirable because they cause a render loop when printed,
      -- but we include them if they are explicitly added since it makes sense under some circumstances as
      -- long as the window does not output directly to a visible velvet window.
      if explicit[result.name] or (result.name ~= 'window.output' and result.name ~= 'pre_render') then
        if type(result) == 'table' then result.time = os.date("%H:%M:%S") end
        print(type(result) == 'string' and result or inspect(result))
      end
    end
  end
})

-- workaround for ghostty not correctly setting associated text when option is held on MacOS
vv.async.run(function()

  local function add_modifier(mod, shorthand)
    local is_key = function(k) return k.key.name == mod end
    local is_release = function(k) return k.key.event_type == 'release' end
    local is_press = function(k) return k.key.event_type == 'press' end

    local key_down = { event = 'on_key', when = function(_, r) return is_key(r.data) and is_press(r.data) end }
    local key_up = { event = 'on_key', when = function(_, r) return is_key(r.data) and is_release(r.data) end }

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
      mappings[string.format("<%s-%s>", shorthand, from)] = function() send(to) end
    end

    while true do
      vv.async.wait(key_down)
      for from, to in pairs(mappings) do keymap.set(from, to) end
      vv.async.wait(key_up)
      for from, _ in pairs(mappings) do keymap.del(from) end
    end
  end

  vv.async.run(add_modifier, 'RIGHT_ALT', 'M')
  vv.async.run(add_modifier, 'RIGHT_SUPER', 'D')
end)

local function pick_session()
  local pick = require('velvet.pick')
  local lst = vv.api.get_servernames()
  local cur = vv.api.get_servername()
  table.sort(lst, function(a, b) return a < b end)

  local options = {}
  for i, text in ipairs(lst) do
    if text ~= cur then
      options[#options + 1] = { text = text }
    end
  end

  pick.select(options, {
    freetext = { enabled = true, prefix = 'New Session: ' },
    on_choice = function(choice)
      if choice ~= cur then
        print(vv.inspect({ pick_session = choice }))
        vv.api.client_reattach(vv.api.get_active_client(), choice.text)
      end
    end,
    prompt = "Select server: "
  })

end

map(map_prefix .. 's', pick_session, "Switch session")

require('clock')
-- require('multi_click')
