local vm_start = vv.api.time()

local function fmt(seconds)
  local str = ""
  local segs = 0
  local max_segs = 2
  local parts = {
    { fmt = 'd', span = 60 * 60 * 24, },
    { fmt = 'h', span = 60 * 60, },
    { fmt = 'm', span = 60, },
    { fmt = 's', span = 1, },
  }
  for _, part in ipairs(parts) do
    if segs < max_segs and seconds > part.span then
      str = str .. ("%.0f%s"):format(seconds / part.span, part.fmt)
      seconds = seconds % part.span
      segs = segs + 1
    end
  end
  if str == '' then return '0s' end
  return str
end

local name = 'uptime'
require('velvet.extras.statusbar').register(name, {
  update_triggers = { 'pre_render' },
  default_options = { background = 'inherit', foreground = 'black', italic = true },
  content = function()
    local now = vv.api.time()
    local vm_time = now - vm_start
    return ("%s (%s)"):format(fmt(now), fmt(vm_time))
  end,
})
return name
