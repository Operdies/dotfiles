local function mem_str(bs)
  bs = 1024 * bs
  local decs = 1
  local postfix = { 'B', 'kB', 'mB', 'gB' }
  while bs > 512 do
    bs = bs / 1024
    decs = decs + 1
  end
  return ("%.2f %s"):format(bs, postfix[decs])
end

local name = 'vm_memory'
require('velvet.extras.statusbar').register(name, {
  update_triggers = { 'pre_render' },
  default_options = { background = 'inherit', foreground = 'yellow', italic = true },
  content = function(x)
    local peak = x.peak or 0
    local used = collectgarbage('count')
    peak = math.max(peak, used)
    x.peak = peak
    local current_usage = mem_str(used)
    local peak_usage = mem_str(peak)
    return ("mem: %s (peak: %s)"):format(current_usage, peak_usage)
  end,
})

return name
