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
    config = function(_, opts)
      -- helper function to parse output
      local function parse_output(proc)
        local result = proc:wait()
        local ret = {}
        if result.code == 0 then
          for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
            -- Remove trailing slash
            line = line:gsub("/$", "")
            ret[line] = true
          end
        end
        return ret
      end

      -- build git status cache
      local function new_git_status()
        return setmetatable({}, {
          __index = function(self, key)
            local ignore_proc = vim.system(
              { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
              {
                cwd = key,
                text = true,
              }
            )
            local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
              cwd = key,
              text = true,
            })
            local ret = {
              ignored = parse_output(ignore_proc),
              tracked = parse_output(tracked_proc),
            }

            rawset(self, key, ret)
            return ret
          end,
        })
      end
      local git_status = new_git_status()

      -- Clear git status cache on refresh
      local refresh = require("oil.actions").refresh
      local orig_refresh = refresh.callback
      refresh.callback = function(...)
        git_status = new_git_status()
        orig_refresh(...)
      end
      require("oil").setup({
        skip_confirm_for_simple_edits = true,
        view_options = {
          is_hidden_file = function(name, bufnr)
            local dir = require("oil").get_current_dir(bufnr)
            local is_dotfile = vim.startswith(name, ".") and name ~= ".."
            -- if no local directory (e.g. for ssh connections), just hide dotfiles
            if not dir then
              return is_dotfile
            end
            -- dotfiles are considered hidden unless tracked
            if is_dotfile then
              return not git_status[dir].tracked[name]
            else
              -- Check if file is gitignored
              return git_status[dir].ignored[name]
            end
          end,
        },
      })
    end,
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
  {
    "ahmedkhalf/project.nvim",
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
    keys = {
      { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
    },
  },
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    event = "VeryLazy",
    branch = '0.1.x',
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
    opts = {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
      },
    },
    config = function(_, opts)
      local function find_git_root()
        -- Use the current buffer's path as the starting point for the git search
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir
        local cwd = vim.fn.getcwd()
        -- If the buffer is not associated with a file, return nil
        if current_file == '' then
          current_dir = cwd
        else
          -- Extract the directory from the current file's path
          current_dir = vim.fn.fnamemodify(current_file, ':h')
        end

        -- Find the Git root directory from the current file's path
        local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')
            [1]
        if vim.v.shell_error ~= 0 then
          print 'Not a git repository. Searching on current working directory'
          return cwd
        end
        return git_root
      end

      -- Custom live_grep function to search in git root
      local function live_grep_git_root()
        local git_root = find_git_root()
        if git_root then
          require('telescope.builtin').live_grep {
            search_dirs = { git_root },
          }
        end
      end

      local t = require('telescope')
      t.setup(opts)
      pcall(t.load_extension, 'fzf')
      pcall(t.load_extension, 'projects')

      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Find recently opened files' })
      vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = 'Find existing buffers' })
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      local function telescope_live_grep_open_files()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end

      vim.keymap.set('n', '<leader>f/', telescope_live_grep_open_files, { desc = 'Search / in Open Files' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Select Buffer' })
      vim.keymap.set('n', '<leader>ff', builtin.git_files, { desc = 'Search Git Files' })
      vim.keymap.set('n', '<leader>fF', "<cmd>Telescope fd<cr>", { desc = 'Search with fd' })
      vim.keymap.set('n', '<leader>ft', builtin.tagstack, { desc = 'Search tag stack' })
      vim.keymap.set('n', '<leader>fj', builtin.jumplist, { desc = 'Search jump list' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search Help' })
      vim.keymap.set('n', '<leader>fg', live_grep_git_root, { desc = 'Grep open files' })
      vim.keymap.set('n', '<leader>fG', builtin.live_grep, { desc = 'Search by Grep' })
      vim.keymap.set('n', '<leader>cd', builtin.diagnostics, { desc = 'Search Diagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search Resume' })

      -- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
      vim.defer_fn(function()
        require('nvim-treesitter.configs').setup {
          -- Add languages to be installed here that you want installed for treesitter
          ensure_installed = { 'bash', 'c', 'c_sharp', 'cpp', 'diff', 'gitcommit', 'go', 'javascript', 'lua', 'markdown', 'python', 'rust', 'svelte', 'tsx', 'typescript', 'vimdoc', 'vim', 'xml', 'yaml' },

          auto_install = true,
          -- Install languages synchronously (only applied to `ensure_installed`)
          sync_install = false,
          -- List of parsers to ignore installing
          ignore_install = {},
          -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
          modules = {},
          highlight = { enable = true },
          indent = { enable = true },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = 'vx',
              node_incremental = 'H',
              scope_incremental = 'K',
              node_decremental = 'L',
            },
          },
          textobjects = {
            select = {
              enable = true,
              lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
              },
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                [']]'] = '@function.outer',
                [']p'] = '@parameter.inner',
              },
              goto_next_end = {
                [']['] = '@function.outer',
              },
              goto_previous_start = {
                ['[['] = '@function.outer',
                ['[p'] = '@parameter.inner',
              },
              goto_previous_end = {
                ['[]'] = '@function.outer',
              },
            },
            swap = {
              enable = true,
              swap_next = {
                ['<leader>a'] = '@parameter.inner',
              },
              swap_previous = {
                ['<leader>A'] = '@parameter.inner',
              },
            },
          },
        }
      end, 0)
    end,
  },
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
}
