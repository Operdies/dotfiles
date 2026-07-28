--- Registers a new cli action, `vv log-events`, accepting one or more events, and printing their associated data to stdout when they are raised.

vv.cli.add_command({
  name = "log-events",
  description = "print the indicated events as json",
  complete = function(...)
    local seen = {}
    for _, v in ipairs({ ... }) do
      seen[v] = true
    end
    local events = vv.async.get_observed_events()
    local completions = { { name = "--json", description = "format the output as json" } }
    for k, v in pairs(events) do
      if not seen[k] then
        completions[#completions + 1] = { name = k, description = type(v) == 'string' and v or nil }
      end
    end
    return completions
  end,
  action = function(_, ...)
    local to_json = require('velvet.json').to_json
    local inspect = function(...)
      local fmt = { ... }
      return to_json(#fmt == 1 and fmt[1] or fmt)
    end
    local params = {}
    local explicit = {}
    for _, arg in ipairs({ ... }) do
      params[#params + 1] = tonumber(arg) or arg
      explicit[arg] = true
    end
    if #params == 0 then return ("No events specified.") end
    for _, result in vv.async.stream(table.unpack(params)) do
      -- normally window_output and pre_render are undesirable because they cause a render loop when printed,
      -- but we include them if they are explicitly added since it makes sense under some circumstances as
      -- long as the window does not output directly to a visible velvet window.
      if explicit[result.event] or (result.event ~= 'window.output' and result.event ~= 'pre_render') then
        local when = os.date("%H:%M:%S")
        print(inspect({ event = result.event, timestamp = when, result.data }))
      end
    end
  end
})
