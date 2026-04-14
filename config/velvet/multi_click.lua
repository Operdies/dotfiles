local M = {
  left_single_click = 'mouse.left.click',
  left_double_click = 'mouse.left.double_click',
  left_triple_click = 'mouse.left.triple_click'
}

vv.async.run(function()
  local timeout = 500
  local when = function(_, clk) return clk.data.event_type == 'mouse_down' and clk.data.mouse_button == 'left' end
  local left_click = { event = 'mouse.click', when = when }
  while true do
    local reg, event = vv.async.wait(left_click)
    vv.events.emit_event(M.left_single_click, event.data)
    reg, event = vv.async.wait(left_click, 'mouse.move', timeout)
    if reg == left_click then
      vv.events.emit_event(M.left_double_click, event.data)
      reg, event = vv.async.wait(left_click, 'mouse.move', timeout)
      if reg == left_click then
        vv.events.emit_event(M.left_triple_click, event.data)
      else
      end
    end
  end
end)

--- @class multi_click.events
--- @field left_single_click velvet.async.event_registration
--- @field left_double_click velvet.async.event_registration
--- @field left_triple_click velvet.async.event_registration

--- @cast M multi_click.events
return M
