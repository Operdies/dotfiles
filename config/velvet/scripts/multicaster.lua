collectgarbage()
print('start')
collectgarbage()
local weakref = setmetatable({}, { __mode = 'kv' })
weakref[1] = vv.async.run(function()
  for i=1,10 do
    collectgarbage()
    print("inner", i)
    vv.async.wait(10)
  end
end)
collectgarbage()
vv.async.wait(weakref[1])
collectgarbage()
print('end')
collectgarbage()

-- local proc = arg[1]
-- local cmd = arg[2]
--
-- local threads = {}
-- local this = vv.api.get_servername()
-- for _, server in ipairs(vv.api.get_servernames()) do
--   if server ~= this then
--     print(string.format("Running %s[%s] on %s", proc, cmd, server))
--     local a = vv.async.run(function()
--       local remote = require('remote_call').create_remote_api(server)
--       local remote_window = remote.window_create_process(proc)
--       remote.window_send_keys(remote_window, cmd .. "\n")
--       vv.async.wait(1000)
--       remote.window_send_keys(remote_window, "<C-d>")
--     end)
--     threads[#threads+1] = a
--   end
-- end
--
-- local function wait_all(args)
--   while #args > 0 do
--     local resolved = vv.async.wait(table.unpack(args))
--     table.remove_if(args, function(x) return x == resolved end)
--   end
-- end
--
-- wait_all(threads)

print('weak test')
local a = {}
local b = {}
setmetatable(a, b)
b.__mode = "kv"         -- now `a' has weak keys
local key = vv.async.run(function() vv.async.wait('**') end)
a[key] = 1
key = vv.async.run(function()  end)
a[key] = 2
key = vv.async.run(function() vv.async.wait('**') end)
a[key] = 3
collectgarbage()       -- forces a garbage collection cycle
for k, v in pairs(a) do print(v) end
print('wait')
vv.async.wait(10)
print('wait done')
collectgarbage()       -- forces a garbage collection cycle
for k, v in pairs(a) do print(v) end
print('weak test end')
