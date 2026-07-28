-- most of this I don't really need but they all serve as great examples of how to
-- do cool things with velvet so I will keep them around, but disabled

-- values stored in |storage| will survive reloads.
-- local storage = require('velvet.runtime_storage').create("config")

-- map("<M-->", function() dwm.inc_inactive_dim(-1.05) end, "Increase inactive dim")
-- map("<M-=>", function() dwm.inc_inactive_dim(-0.05) end, "Decrease inactive dim")
-- local paint = require('paint')
-- map_prefix("paint", paint.create_paint, "Open paint window")
-- require('coffee').enable()
-- require('log-events')
-- local disable_keymap = require('disable_keymap')
-- map("<C-x><space>", disable_keymap, "Temporarily disable keymap")
-- require('nordic_keys')

-- do
--   local logpanel = require('velvet.diagnostics.logpanel')
--   local function update_logpanel_state()
--     if storage.logpanel_enabled then
--       logpanel.enable()
--     else
--       logpanel.disable()
--     end
--   end
--   local function toggle_logpanel()
--     storage.logpanel_enabled = not storage.logpanel_enabled
--     update_logpanel_state()
--   end
--   map('<M-x>logs', toggle_logpanel, "Toggle logpanel")
--   update_logpanel_state()
-- end

