local M = {}
function M.pick_session()
  local this = vv.api.get_servername()
  local function get_servers()
    local lst = vv.api.get_servernames()
    table.sort(lst, function(a, b) return a < b end)

    local options = {}
    for _, text in ipairs(lst) do
      if text ~= this then
        options[#options + 1] = { text = text }
      end
    end
    return options
  end
  local pick = require('velvet.pick')

  pick.select(get_servers(), {
    freetext = { enabled = true, prefix = 'New Session: ' },
    mappings = {
      {
        keys = "<C-w>",
        action = function(sel)
          local p = pick:get_active_picker()
          if p == nil or not p:valid() then return end
          local co = coroutine.running()
          vv.api.process_spawn({ "vv", "-S", sel.text, "quit" }, {
            on_exit = function() coroutine.resume(co) end,
            input = "",
          })
          coroutine.yield()
          local servers = get_servers()
          if #servers == 0 then
            pick.dispose()
          else
            pick.update_items(servers)
          end
        end,
        description = "Close selected session"
      },
    },
    on_choice = function(choice)
      if choice ~= this then
        vv.api.client_reattach(vv.api.get_active_client(), choice.text)
      end
    end,
    prompt = "Select server: "
  })
end

return M
