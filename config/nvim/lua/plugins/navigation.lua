return {
  {
    "wellle/targets.vim",
    event = "VeryLazy",
  },
  {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    event = 'VeryLazy',
    version = '2.*',
    opts = {
      hint = 'floating-big-letter',
    },
    config = function(_, opts)
      local wp = require('window-picker')
      wp.setup(opts)
      -- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
      local pick = function()
        local win = wp.pick_window()
        if win then
          vim.api.nvim_set_current_win(win)
        end
      end
      vim.keymap.set('n', '<C-w>f', pick, { desc = "Pick a window" })
    end,
  },
}
