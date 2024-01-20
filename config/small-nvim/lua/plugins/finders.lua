return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    keys = {
      { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
      { "<leader>ff", "<Cmd>Telescope find-files<CR>", desc = "Files" },
      { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Live Grep" },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },
  {
    "telescope.nvim",
    dependencies = {
      -- project management
      {
        "ahmedkhalf/project.nvim",
        opts = {
          manual_mode = true,
        },
        event = "VeryLazy",
        config = function(_, opts)
          require("project_nvim").setup(opts)
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("projects")
          end)
        end,
      },
    },
  }
}
