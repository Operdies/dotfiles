require("utils").create_keymap_group("<leader>r", "+run")

return {
  {
    "Operdies/gwatch.nvim",
    dev = true,
    keys = {
      { "<leader>ct", '<cmd>lua require("gwatch").toggle()<cr>', desc = "Toggle Gwatch", mode = "n" },
      { "<leader>cs", '<cmd>lua require("gwatch").start()<cr>', desc = "Start Gwatch", mode = "n" },
      { "<leader>cx", '<cmd>lua require("gwatch").stop()<cr>', desc = "Stop Gwatch", mode = "n" },
      { "<leader>cc", '<cmd>lua require("gwatch").reload()<cr>', desc = "Reload Gwatch", mode = "n" },
      { "<leader>c,", '<cmd>lua require("gwatch").settings()<cr>', desc = "Override Settings", mode = "n" },
      { "<C-q>", '<cmd>lua require("gwatch").trigger()<cr>', desc = "Trigger gwatch run", mode = "n" },
    },
    opts = {
      -- The width of the UI window
      ["window width"] = 80,
      ["window height"] = 10,
      ["window position"] = "bottom",
      ["trigger"] = "hotkey",
      -- Options in this block are the default independent of language
      default = {
        -- Check the output of `gwatch --help` for specific information about flags
        eventMask = "write",
        mode = "block",
        patterns = "**",
        -- %e and %f respectively expand to the event, and the file it affected
        command = "echo %e %f",
      },
      -- Settings for a specific filetype override default settings
      lang = {
        -- lua = {
        --   patterns = "**.lua",
        --   callback = function()
        --     require("sniprun").run("n")
        --   end,
        -- },
        c = {
          patterns = { "**.c", "Makefile" },
          command = "make",
          mode = "block",
        },
        go = {
          patterns = { "**.go", "go.mod" },
          -- Not using 'go run .' because that doesn't return the actual running process PID.
          -- gwatch will be unable to kill spawned instances of the process.
          command = "clear; go build -o ./out .; ./out",
        },
        rust = {
          mode = "kill",
          patterns = { "**.rs", "Cargo.toml" },
          -- command = "cargo test -- --nocapture",
          command = "cargo run",
        },
      },
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "<leader>en",
        function()
          require("trouble").next({ skip_groups = true, jump = true })
        end,
        desc = "Trouble Next",
      },
      {
        "<leader>ep",
        function()
          require("trouble").previous({ skip_groups = true, jump = true })
        end,
        desc = "Trouble Previous",
      },
      {
        "<leader>ef",
        function()
          require("trouble").first({ skip_groups = true, jump = true })
        end,
        desc = "Trouble First",
      },
      {
        "<leader>el",
        function()
          require("trouble").last({ skip_groups = true, jump = true })
        end,
        desc = "Trouble Last",
      },
    },
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
    "christoomey/vim-tmux-navigator",
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      {
        "<C-h>",
        function()
          vim.cmd([[TmuxNavigateLeft]])
        end,
        desc = "Tmux Left",
      },
      {
        "<C-l>",
        function()
          vim.cmd([[TmuxNavigateRight]])
        end,
        desc = "Tmux Right",
      },
      {
        "<C-k>",
        function()
          vim.cmd([[TmuxNavigateUp]])
        end,
        desc = "Tmux Up",
      },
      {
        "<C-j>",
        function()
          vim.cmd([[TmuxNavigateDown]])
        end,
        desc = "Tmux Down",
      },
    },
  },
  {
    "codethread/qmk.nvim",
    config = function()
      ---@type qmk.UserConfig
      local conf = {
        name = "LAYOUT_first",
        layout = {
          "x x x x x _ _ _ x x x x x",
          "x x x x x _ _ _ x x x x x",
          "x x x x x x _ x x x x x x",
          "x x x x x x _ x x x x x x",
        },
      }
      require("qmk").setup(conf)
    end,
  },
}
