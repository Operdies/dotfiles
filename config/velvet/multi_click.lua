local M = {
  left_single_click = 'mouse.left.click',
  left_double_click = 'mouse.left.double_click',
  left_triple_click = 'mouse.left.triple_click'
}

vv.async.run(function()
  local timeout = 500
  local when = function(_, _, clk) return clk.event_type == 'mouse_down' and clk.mouse_button == 'left' end
  local left_click = { event = 'mouse.click', when = when }
  while true do
    local evt, double, triple
    local _, _, single = vv.async.wait(left_click)
    vv.events.emit_event(M.left_single_click, single)
    evt, _, double = vv.async.wait(left_click, 'mouse.move', timeout)
    if evt == left_click then
      vv.events.emit_event(M.left_double_click, double)
      evt, _, triple = vv.async.wait(left_click, 'mouse.move', timeout)
      if evt == left_click then
        vv.events.emit_event(M.left_triple_click, triple)
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
