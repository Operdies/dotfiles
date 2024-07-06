return {
  {
    "stevearc/overseer.nvim",
    keys = {
      {
        "<leader>rp",
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
        "<cmd>OverseerToggle<cr>",
        desc = "Toggle task list (Overseer)",
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
