local M = {}

local velvet_window = require('velvet.window')
local dwm = require('velvet.layout.dwm')

function M.pick()
  local visible_indicator = "(*) "
  local not_visible_indicator = "    "
  local pick = require('velvet.pick')
  local lst = vv.api.get_windows()
  table.sort(lst, function(a, b) return a < b end)
  local items = {}
  local initial_index = -1
  local current_focus = vv.api.get_focused_window()
  for _, id in ipairs(lst) do
    local w = velvet_window.from_handle(id)
    if not w:is_lua() and not w:get_parent() then
      local display = w:get_friendly_title()
      local prefix = w:get_visibility() and visible_indicator or not_visible_indicator
      items[#items + 1] = { text = prefix .. display, win = w }
      if id == current_focus then initial_index = #items end
    end
  end

  local underlay = nil
  local prev_preview = { win = nil, z = nil, visible = nil, alpha = nil }
  local function restore_prev()
    local w = prev_preview and prev_preview.win
    if w and w:valid() then
      w:set_z_index(prev_preview.z)
      w:set_visibility(prev_preview.visible)
      w:set_alpha(prev_preview.alpha)
    end
  end
  local function dispose()
    restore_prev()
    if underlay and underlay.close then underlay:close() end
  end
  pick.select(items, {
    on_preview = function(sel)
      local picker = assert(pick.get_active_picker())
      if not underlay then
        underlay = picker:create_child_window()
        underlay:set_z_index(picker:get_z_index() - 2)
      end
      local ts = vv.api.get_screen_geometry()
      underlay:set_geometry({ left = 1, top = 1, width = ts.width, height = ts.height })
      underlay:set_background_color(vv.options.theme.background)
      underlay:clear()
      restore_prev()
      prev_preview = { win = sel.win, z = sel.win:get_z_index(), visible = sel.win:get_visibility(), alpha = sel.win
      :get_alpha() }
      sel.win:set_z_index(picker:get_z_index() - 1)
      sel.win:set_visibility(true)
      sel.win:set_alpha(1.0)
      sel.win:configure_frame({ enabled = true, color = 'magenta' })
    end,
    on_cancel = function()
      dispose()
    end,
    on_choice = function(sel)
      sel.win:focus()
      dwm.make_visible(sel.win)
      dispose()
    end,
    prompt = "Focus window: ",
    initial_selection = initial_index,
  })
end

return M
