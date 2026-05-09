local M = {}
local process = require('process')
local function remote_call(servername, fn, ...)
  local args = {}
  for i, v in ipairs({ ... }) do
    args[i] = vv.inspect(v)
  end
  local payload = string.format("print(vv.inspect(%s(%s)))", fn, table.concat(args, ", "))
  local proc = process.spawn({ "vv", "--socket", servername, "lua", "-" },
    { stdin = payload }
  )

  local stdout, stderr = proc:read_to_end()
  if stderr then printerr(stderr) end

  local ok, err = load('return ' .. stdout)
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
