return {
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
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
      vim.keymap.set('n', '<leader>ff', "<cmd>Telescope fd<cr>", { desc = 'Search with fd' })
      vim.keymap.set('n', '<leader>fF', builtin.git_files, { desc = 'Search Files' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search Help' })
      vim.keymap.set('n', '<leader>fg', live_grep_git_root, { desc = 'Grep git root' })
      vim.keymap.set('n', '<leader>fG', builtin.live_grep, { desc = 'Search by Grep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search Diagnostics' })
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
              },
              goto_next_end = {
                [']['] = '@function.outer',
              },
              goto_previous_start = {
                ['[['] = '@function.outer',
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