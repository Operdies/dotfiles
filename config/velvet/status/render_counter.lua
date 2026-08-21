local name = 'render_counter'
require('velvet.extras.statusbar').register(name, {
  update_triggers = { 'pre_render' },
  default_options = { background = 'inherit', foreground = 'bright_green' },
  content = function(data, _, y)
    local count = data.count or 1
    data.count = count + 1
    return {{ text = "renders: " .. count }, { text = y and (' (' .. y.cause .. ')'), italic = true }}
  end,
})
return name
