return {
  {
    enabled = false,
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    -- enabled = false,
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 10000,
          tabline = 10000,
          winbar = 10000,
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'diff', 'diagnostics' },
        lualine_c = {
          {
            'filename',
            path = 1,
          }
        },
        lualine_x = { 'filetype', 'encoding' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            path = 1,
          }
        },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      winbar = {},
      tabline = {},
      inactive_winbar = {},
      extensions = { 'oil', 'lazy', 'overseer', 'nvim-dap-ui', 'trouble', 'toggleterm', 'quickfix', 'man' },
    },
  },
  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    config = function(_, opts)
      if 'Windows_NT' == vim.loop.os_uname().sysname then
        vim.cmd [[
            let &shell = 'powershell'
            let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
            let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
            let &shellpipe  = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
            set shellquote= shellxquote=
            ]]
      end

      opts.shell = vim.o.shell
      local toggleterm = require("toggleterm")
      toggleterm.setup(opts)
    end,
    keys = {
      { "<C-\\>" },
      {
        "<leader>gg",
        function()
          require("toggleterm.terminal").Terminal
              :new({ cmd = "lazygit", hidden = true, direction = "float" })
              :toggle()
        end,
        desc = "lazygit",
      },
    },
    opts = {
      direction = "float",
      size = 20,
      open_mapping = "<C-\\>",
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = false,
      persist_size = true,
      persist_mode = false,
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
      },
      autochdir = true,
      env = {
        EDITOR = "nvr -l",
      },
    },
  },
  {
    lazy = false,
    "akinsho/bufferline.nvim",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        close_command = "bp|bd #",
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    dependencies = {
      {
        "folke/persistence.nvim",
        event = "BufReadPre", -- this will only start session saving when an actual file was opened
        opts = {}
      }
    },
    lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
    opts = function()
      local logo = [[

     █████╗    ██╗       ██████╗   ██╗   ██╗
    ██╔══██╗   ██║       ██╔═══╝    ██╗ ██╔╝
    ██║  ██║   ██║       █████╗      ████╔╝
    ███████║   ██║       ██╔══╝     ██╔ ██╗
    ██╔══██║   ███████╗  ██████╗   ██╔╝  ██╗
    ╚═╝  ╚═╝   ╚══════╝  ╚═════╝   ╚═╝   ╚═╝
    ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",

        hide = {
          -- this is taken care of by lualine

          -- enabling this messes up the actual laststatus setting after loading a file

          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          -- stylua: ignore
          center = {
            { action = 'Oil ', desc = " Browse Files", icon = " ", key = "o" },
            { action = 'Telescope git_files', desc = " Find File", icon = " ", key = "f" },
            { action = 'Telescope oldfiles', desc = " Recent Files", icon = " ", key = "r" },
            { action = function() require("persistence").load() end, desc = " Restore Session", icon = " ", key = "s" },
            { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
            { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit", icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- open dashboard after closing lazy
      if vim.o.filetype == "lazy" then
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(vim.api.nvim_get_current_win()),
          once = true,
          callback = function()
            vim.schedule(function()
              vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
            end)
          end,
        })
      end

      return opts
    end,
  },
}
