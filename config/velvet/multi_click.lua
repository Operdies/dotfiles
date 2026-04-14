--- @class multi_click.events
--- @field left_single_click velvet.async.event
--- @field left_double_click velvet.async.event
--- @field left_triple_click velvet.async.event

--- @type multi_click.events
local M = {
  ---@diagnostic disable-next-line: assign-type-mismatch
  left_single_click = 'mouse.left.click',
  ---@diagnostic disable-next-line: assign-type-mismatch
  left_double_click = 'mouse.left.double_click',
  ---@diagnostic disable-next-line: assign-type-mismatch
  left_triple_click = 'mouse.left.triple_click'
}

vv.async.run(function()
  vv.async.run(function()
    while true do
      local clk = vv.async.wait_for_mouse_click()
      if clk.event_type == 'mouse_down' and clk.mouse_button == 'left' then
        vv.events.emit_event(M.left_single_click, clk)
      end
    end
  end)

  local timeout = 500
  local when = function(_, clk) return clk.event_type == 'mouse_down' and clk.mouse_button == 'left' end
  local left_click = { event = 'mouse.click', when = when }
  while true do
    local evt, double, triple
    -- click
    vv.async.wait_for_mouse_click(when, nil)
    vv.events.emit_event(M.left_single_click, double)
    evt, double = vv.async.wait(left_click, 'mouse.move', timeout)
    if evt == left_click.event then
      vv.events.emit_event(M.left_double_click, double)
      evt, triple = vv.async.wait(left_click, 'mouse.move', timeout)
      if evt == left_click.event then
        vv.events.emit_event(M.left_triple_click, triple)
      else
      end
    end
  end
end)

return M
