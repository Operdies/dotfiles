local keymap = require('velvet.keymap')
return function()
  keymap:set_passthrough(true)
  local function is_escape_down(args)
    return args.key.name == 'ESCAPE' and args.key.event_type == 'press'
  end
  -- triple tap escape to disable
  --- @async
  vv.async.run(function()
    local timeout = 300
    while keymap:get_passthrough() do
      vv.async.wait_for_on_key(nil, is_escape_down)
      if vv.async.wait_for_on_key(timeout, is_escape_down) and vv.async.wait_for_on_key(timeout, is_escape_down) then
        keymap:set_passthrough(false)
        break
      end
    end
  end)
end
