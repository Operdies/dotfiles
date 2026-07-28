local function setup(bar)
  local proc = require('velvet.process')
  local function get_battery()
    local p = proc.spawn('acpi', { stdin = false, stderr = false })
    local line = assert(p.stdout:line())
    local charging = line:match('Charging')
    local pct, hours, minutes = line:match('(%d+%%), 0?(%d+):0?(%d+):0?(%d+)')
    local charge_state = charging and "󰂄" or "󰁿"
    local pretty = string.format("%s %sh %sm (%s)", charge_state, hours, minutes, pct)
    return pretty
  end
  if get_battery() then
    bar.register('battery', {
      default_options = { foreground = 'black', background = 'peach' },
      content = get_battery,
      update_triggers = { 60000 }
    })
    local center = bar:get_center()
    table.insert(center, 'battery')
    bar:set_center(center)
  end
end

-- this will error() if acpi cannot be spawned, which is what we want
vv.api.process_spawn('acpi', { input = '' })
return {
  setup = setup
}
