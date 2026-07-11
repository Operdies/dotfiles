local map_prefix = "<C-x>"
require('velvet.presets.dwm').setup({ prefix = map_prefix, startup = { spawn_shell = true }, shutdown = { on_last_window_exit = true }})

-- values stored in |storage| will survive reloads.
local storage = require('velvet.runtime_storage').create("config")

local dwm = require('velvet.layout.dwm')
local keymap = require('velvet.keymap')

--- @param lhs string
--- @param func fun()
--- @param opt string|velvet.keys.set.options
local map = function(lhs, func, opt) keymap:set(lhs, func, type(opt) == 'table' and opt or { description = opt }) end

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
keymap:remap_key('§', '`')
keymap:remap_key('±', '~')

local quake = require('velvet.extras.quake')
local quake1 = quake.create('zsh', 'default')
local lazygit = quake.create('lazygit', 'lazygit')
map(map_prefix .. "<C-\\>", quake1.toggle, "Toggle Zsh Quake")
map(map_prefix .. "<C-]>", lazygit.toggle, "Toggle Lazygit Quake")

map("<C-x><space>", function()
  keymap:set_passthrough(true)
  local registration = { event = 'on_key', when = function(_, result) return result.data.key.name == 'ESCAPE' and result.data.key.event_type == 'press' end }
  -- triple tap escape to disable
  vv.async.run(function()
    local timeout = 200
    while keymap:get_passthrough() do
      vv.async.wait(registration)
      if vv.async.wait(registration, timeout) and vv.async.wait(registration, timeout) then
        keymap:set_passthrough(false)
        break
      end
    end
  end)
end, "Temporarily disable keymap")

map("<M-`>", dwm.select_previous_view, { description = "Select the previous view" })

vv.cli.add_command({
  name = "log",
  description = "print all system messages",
  action = function()
    for _, e in vv.async.stream('system_message') do
      if e.data.level == 'error' then
        printerr(e.data.message)
      else
        print(e.data.message)
      end
    end
  end,
})

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
        local when = os.date("%H:%M:%S")
        print(inspect({name = result.name, timestamp = when, result.data}))
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
      for from, to in pairs(mappings) do keymap:set(from, to) end
      vv.async.wait(key_up)
      for from, _ in pairs(mappings) do keymap:del(from) end
    end
  end

  vv.async.run(add_modifier, 'RIGHT_ALT', 'M')
  vv.async.run(add_modifier, 'RIGHT_SUPER', 'D')
end)

local function pick_session()
  local this = vv.api.get_servername()
  local function get_servers()
    local lst = vv.api.get_servernames()
    table.sort(lst, function(a, b) return a < b end)

    local options = {}
    for i, text in ipairs(lst) do
      if text ~= this then
        options[#options + 1] = { text = text }
      end
    end
    return options
  end
  local pick = require('velvet.pick')

  pick.select(get_servers(), {
    freetext = { enabled = true, prefix = 'New Session: ' },
    mappings = {
      {
        keys = "<C-w>",
        action = function(sel) 
          local p = pick:get_active_picker()
          if p and p:valid() then
            local proc = vv.api.process_spawn({ "vv", "-S", sel.text, "quit" })
            vv.async.run(function()
              vv.async.wait({ event = 'process.exited', when = function(_, e) return e.data.id == proc end })
              local servers = get_servers()
              if #servers == 0 then
                pick.dispose()
              else
                pick.update_items(servers)
              end
            end)
          end
        end,
        description = "Close selected session"
      },
    },
    on_choice = function(choice)
      if choice ~= this then
        vv.api.client_reattach(vv.api.get_active_client(), choice.text)
      end
    end,
    prompt = "Select server: "
  })
end


map(map_prefix .. 's', pick_session, "Switch session")
require('clock')

local mocha = {
  -- extra colors not mapped to ansi colors
  rosewater = "#f5e0dc",
  flamingo = "#f2cdcd",
  pink = "#f5c2e7",
  mauve = "#cba6f7",
  red = "#f38ba8",
  maroon = "#eba0ac",
  peach = "#fab387",
  yellow = "#f9e2af",
  green = "#a6e3a1",
  teal = "#94e2d5",
  sky = "#89dceb",
  sapphire = "#74c7ec",
  blue = "#89b4fa",
  lavender = "#b4befe",
  text = "#cdd6f4",
  ['subtext 1'] = "#bac2de",
  ['subtext 0'] = "#a6adc8",
  ['overlay 2'] = "#9399b2",
  ['overlay 1'] = "#7f849c",
  ['overlay 0'] = "#6c7086",
  ['surface 2'] = "#585b70",
  ['surface 1'] = "#45475a",
  ['surface 0'] = "#313244",
  base = "#1e1e2e",
  mantle = "#181825",
  crust = "#11111b",
}

for k, v in pairs(mocha) do
  vv.options.theme[k] = v
end

dwm.reserve(0, 0, 1, 0)
local status = require('velvet.extras.statusbar').create({ where = 'bottom', background = 'mantle' })
status:add_segment('right'):update({ { text = vv.api.get_servername():upper(), fg = '#000000', bold = true, bg = 'red' } })

local function battery_status()
  local process = require('process')
  local loop = 'while acpi; do sleep 10; done'
  local poll_id = storage.poll_id
  if poll_id then
    pcall(vv.api.process_kill, poll_id)
    poll_id = nil
  end
  local acpi_poller
  if poll_id then
    acpi_poller = process.wrap(poll_id)
  else
    acpi_poller = process.spawn({ 'bash', '-c', loop })
  end

  local seg = status:add_segment('center')
  vv.async.defer(function() seg:remove() end)
  for _, line in acpi_poller:lines() do
    local charging = line:match('Charging')
    local bat = { charging = "󰂄", discharging = "󰁿" }
    local pct, time = line:match('(%d+%%), (%d+:%d+:%d+)')
    local pow = string.format("%s %s (%s)", charging and bat.charging or bat.discharging, time, pct)
    seg:update({ { text = pow, bold = true, bg = '#ffee60', fg = 'black' } })
  end
end
vv.async.run(battery_status)

local function dwm_tags()
  local function tag_occupied(tags, tag)
    for _, set in pairs(tags) do
      if set[tag] then return true end
    end
    return false
  end
  local seg = status:add_segment('left')
  vv.async.defer(seg.remove)
  while true do
    local segments = {}
    local state = dwm.get_state()
    for i, v in ipairs(state.view) do
      if v or tag_occupied(state.tags, i) then
        segments[#segments + 1] = {
          bg = v and 'red' or 'blue',
          fg = '#000000',
          text = i,
          bold = v,
          italic = not v,
          underline = false,
        }
      end
    end
    seg:update(segments)
    dwm.wait_for_state_change()
  end
end
vv.async.run(dwm_tags)

local function status_clock()
  local clock = status:add_segment('right')
  while true do
    local text = tostring(os.date('%H:%M'))
    clock:update({ { text = text, bg = 'blue', fg = '#000000', bold = true } })
    local current_seconds = tonumber(os.date('%S'))
    local next_minute = (60 - current_seconds) * 1000
    vv.async.wait(next_minute)
  end
end
vv.async.run(status_clock)
