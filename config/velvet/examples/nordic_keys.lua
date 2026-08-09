local keymap = require('velvet.keymap')

-- workaround for ghostty not setting associated text when option is held on MacOS
vv.async.run(function()

  ---@async
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

