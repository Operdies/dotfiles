local cpu_start = os.clock()

local name = 'cpu_time'
require('velvet.extras.statusbar').register(name, {
  update_triggers = { 'pre_render' },
  default_options = { background = 'inherit', foreground = 'magenta', italic = true },
  content = function()
    local cpu_total = os.clock() - cpu_start
    return ("cpu time: %.1fs"):format(cpu_total)
  end,
})
return name
