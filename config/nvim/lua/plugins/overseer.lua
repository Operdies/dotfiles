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
          vim.cmd [[OverseerOpen]]
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
        "<leader>rb",
        function()
          if OVERSEER_PREV_RUN_BUILD ~= nil then
            OVERSEER_PREV_RUN_BUILD:dispose(true)
          end

          local build_options = {
            build = { available = vim.fn.executable("./run") == 1, cmd = "./run", args = {} },
          }

          for _, build in pairs(build_options) do
            if build.available then
              local task = require('overseer').new_task({
                cmd = { build.cmd },
                args = build.args,
                components = {
                  { "restart_on_save", delay = 50 },
                  { "on_output_quickfix", open = true },
                  "default"
                },
              })
              task:start()
              -- local win = vim.api.nvim_get_current_win()
              -- vim.cmd('OverseerOpen')
              -- vim.api.nvim_set_current_win(win)
              OVERSEER_PREV_RUN_BUILD = task
              return
            end
          end
        end,
        desc = "Start a watch + build.sh task",
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
