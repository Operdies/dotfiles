--- I don't have a use for this, I just had to check it in because it's so cool!
--- Definitely need to marinate on ffi to figure out if this feature alone warrants moving from PUC+JIT to only supporting luajit.
--- There's definitely a wow factor, but I don't immediately see a motivating example in velvet.
local ffi = require('ffi')

local function ffitest()
  ffi.cdef [[
char *realpath(const char *path, char *resolved_path);
]]
  local buffer = ffi.new('char[?]', 4096)
  ffi.C.realpath("/proc/self/exe", buffer)
  print(ffi.string(buffer))
end

local yes, why = pcall(ffitest)
if not yes then printerr(why) end
