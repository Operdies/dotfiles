local M = {}
local function remote_call(servername, fn, ...)
  local proc = vv.api.process_spawn({ "vv", "--socket", servername, "lua", "-" })
  local output = {
    event = "process.output",
    when = function(_, e)
      return e.data.channel == 'stdout' and e.data.id == proc
    end
  }
  local error = {
    event = "process.output",
    when = function(_, e)
      return e.data.channel == 'stderr' and e.data.id == proc
    end
  }
  local exit = { event = "process.exited", when = function(_, evt) return evt.data.id == proc end }
  local args = {}
  for i, v in ipairs({...}) do
    args[i] = vv.inspect(v)
  end
  local payload = string.format("print(vv.inspect(%s(%s)))", fn, table.concat(args, ", "))
  vv.api.process_stdin_write(proc, payload)
  vv.api.process_stdin_close(proc)

  local strings = { "return " }
  for reg, evt in vv.async.stream(output, error, exit) do
    if reg == exit then break end
    if reg == output then strings[#strings + 1] = evt.data.output end
    if reg == error then printerr(evt.data.output) end
  end

  local text = table.concat(strings, "")
  local ok, err = load(text)
  if not ok then error(err) end
  local loaded = ok()
  return loaded
end

--- @return velvet.api
function M.create_remote_api(servername)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...) return remote_call(servername, "vv.api." .. k, ...) end
    end,
  })
end

return M
