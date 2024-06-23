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
  {
    "stevearc/oil.nvim",
    cmd = { "Oil " },
    config = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "<leader>o",
        '<cmd>lua require("oil").open()<CR>',
        desc = "Open parent directory",
      },
    },
  },
  {
    'axkirillov/hbac.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    event = "VeryLazy",
    opts = {
      autoclose                  = false,
      threshold                  = 10,
      close_command              = function(bufnr)
        vim.api.nvim_buf_delete(bufnr, {})
      end,
      close_buffers_with_windows = false,
    },
    config = function(_, opts)
      local hbac = require('hbac')
      local actions = require("hbac.telescope.actions")

      opts['telescope'] = {
        sort_mru = true,
        sort_lastused = true,
        selection_strategy = "row",
        use_default_mappings = false,
        mappings = {
          i = {
            ["<C-q>"] = actions.close_unpinned,
            ["<C-w>"] = actions.delete_buffer,
            ["<C-e>"] = actions.toggle_pin,
          },
          n = {
            ["<C-q>"] = actions.close_unpinned,
            ["<C-w>"] = actions.delete_buffer,
            ["<C-e>"] = actions.toggle_pin,
          },
        },
        -- Pinned/unpinned icons and their hl groups. Defaults to nerdfont icons
        pin_icons = {
          pinned = { "󰐃 ", hl = "DiagnosticOk" },
          unpinned = { "󰤱 ", hl = "DiagnosticError" },
        },
      }

      hbac.setup(opts)
      require('telescope').load_extension('hbac')

      -- Overrides existing telescope.builtins.buffers bind with hbac variant
      vim.keymap.set('n', '<leader>fb', "<cmd>Telescope hbac buffers<CR>", { desc = 'Select hbac buffer' })
    end,
  },
  {
    "ggandor/leap.nvim",
    enabled = true,
    keys = {
      { "s",  mode = { "n", "x", "o" }, desc = "Leap Forward to" },
      { "S",  mode = { "n", "x", "o" }, desc = "Leap Backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
    },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },
}
