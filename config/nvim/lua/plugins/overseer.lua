return {
  {
    "stevearc/overseer.nvim",
    keys = {
      {
        "<leader>rl",
        "<cmd>OverseerLoadBundle<cr>",
        desc = "Pick a saved task bundle",
      },
      {
        "<leader>rw",
        "<cmd>OverseerQuickAction watch<cr>",
        desc = "Rerun on save (Overseer)",
      },
      {
        "<leader>rt",
        "<cmd>OverseerRun<cr>",
        desc = "Run task (Overseer)",
      },
      {
        "<leader>rT",
        function()
          local win = vim.api.nvim_get_current_win()
          vim.cmd('OverseerToggle')
          vim.api.nvim_set_current_win(win)
        end,
        desc = "Toggle task list (Overseer)",
      },
      {
        "<leader>rp",
        function()
          vim.cmd[[OverseerOpen]]
          local sidebar = require("overseer.task_list.sidebar")
          local sb = sidebar.get_or_create()
          sb:toggle_preview()
        end,
        desc = "Open action output in floating preview window",
      },
      {
        "<leader>ro",
        "<cmd>OverseerQuickAction open float<cr>",
        desc = "Open action output in floating window",
      },
      {
        "<leader>rq",
        "<cmd>OverseerQuickAction open output in quickfix<cr>",
        desc = "Open action output in quick fix",
      },
      {
        "<leader>rr",
        "<cmd>OverseerQuickAction restart<cr>",
        desc = "Restart the most recent overseer action",
      },
    },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 15,
        default_detail = 2,
        dap = true,
        bindings = {
          ["<C-c>"] = "<cmd>OverseerQuickAction stop<cr>",
          ["<C-r>"] = "<cmd>OverseerQuickAction restart<cr>",
        }
      },
    },
  },
}
