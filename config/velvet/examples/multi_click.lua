---@diagnostic disable: invisible
local single = vv.async.event_source()
local double = vv.async.event_source()
local triple = vv.async.event_source()
local M = {
  left_single_click = single:listener(),
  left_double_click = double:listener(),
  left_triple_click = triple:listener(),
}

vv.async.run(function()
  local timeout = 500
  local when = function(_, clk) return clk.data.event_type == 'mouse_down' and clk.data.mouse_button == 'left' end
  local left_click = { event = 'mouse.click', when = when }
  while true do
    local data, event = vv.async.wait(left_click)
    single:emit(data)
    data, event = vv.async.wait(left_click, 'mouse.move', timeout)
    if event == left_click then
      double:emit(data)
      data, event  = vv.async.wait(left_click, 'mouse.move', timeout)
      if event == left_click then
        triple:emit(data)
      end
    end
  end
end)

--- @class multi_click.events
--- @field left_single_click velvet.async.event_listener<velvet.api.mouse_click.event_args>
--- @field left_double_click velvet.async.event_listener<velvet.api.mouse_click.event_args>
--- @field left_triple_click velvet.async.event_listener<velvet.api.mouse_click.event_args>

--- @cast M multi_click.events
return M
