local proc = arg[1]
local cmd = arg[2]

local threads = {}
local this = vv.api.get_servername()
for _, server in ipairs(vv.api.get_servernames()) do
  if server ~= this then
    print(string.format("Running %s[%s] on %s", proc, cmd, server))
    local a = vv.async.run(function()
      local remote = require('remote_call').create_remote_api(server)
      local remote_window = remote.window_create_process(proc)
      remote.window_send_keys(remote_window, cmd .. "\n")
      vv.async.wait(1000)
      remote.window_send_keys(remote_window, "<C-d>")
    end)
    threads[#threads+1] = a
  end
end

local function wait_all(args)
  while #args > 0 do
    local resolved = vv.async.wait(table.unpack(args))
    table.remove_if(args, function(x) return x == resolved end)
  end
end

wait_all(threads)
