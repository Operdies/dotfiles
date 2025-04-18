return {
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      "hrsh7th/cmp-nvim-lsp-signature-help",

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
      -- ctag support
      'quangnguyen30192/cmp-nvim-tags',
      -- completion scoring etc.
      "p00f/clangd_extensions.nvim",
    },
    config = function(_, _)
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      require('luasnip.loaders.from_vscode').lazy_load()
      luasnip.config.setup {}

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp_defaults = require("cmp.config.default")()

      local sorting = cmp_defaults.sorting or {}
      sorting.comparators = sorting.comparators or {}
      table.insert(sorting.comparators, 1, require("clangd_extensions.cmp_scores"))

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          auto_bracktes = {},
          completeopt   = 'menu,menuone,noinsert',
          -- autocomplete  = false,
        },
        sorting = sorting,
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ['<C-e>'] = function()
            if cmp.get_selected_entry() == nil then
              cmp.complete()
            else
              cmp.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              })
            end
          end,
          ['<C-a>'] = cmp.mapping.abort(),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      })
    end,
  },
  {
    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',
    enabled = false,
  },
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        'williamboman/mason.nvim',
        opts = {
          registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry",
          },
        },
        config = function(_, opts)
          -- mason-lspconfig requires that these setup functions are called in this order before setting up the servers.
          require('mason').setup(opts)
          require('mason-lspconfig').setup()
        end
      },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function(_, _)
      local on_attach = function(_, bufnr)
        local nmap = function(keys, func, desc, modes)
          if desc then
            desc = 'LSP: ' .. desc
          end

          vim.keymap.set(modes or 'n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>cr', vim.lsp.buf.rename, 'Rename')
        nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
        nmap('<leader>cf', vim.lsp.buf.format, 'Format Buffer', 'n')
        nmap('<leader>cf', vim.lsp.buf.format, 'Format Range', 'v')

        nmap('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
        nmap('gr', require('telescope.builtin').lsp_references, 'Goto References')
        nmap('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
        nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type Definition')
        nmap('<leader>cs', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
        nmap('<leader>cS', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

        -- See `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
        -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

        -- Lesser used LSP functionality
        nmap('gD', vim.lsp.buf.declaration, 'Goto Declaration')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, 'Workspace Add Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Workspace Remove Folder')
        nmap('<leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, 'Workspace List Folders')
        nmap('<leader>i', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, "Toggle Inlay Hints")
      end
      on_attach(nil, nil);

      local lspconfig = require('lspconfig')
      local servers = {
        clangd = {
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>",
              { buffer = bufnr, desc = "Switch Source/Header" })
          end,
          root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find({
              "Makefile",
              "compile_commands.json",
              "configure.ac",
              "configure.in",
              "config.h.in",
              -- if meson.build exists in nested source directories, we get a separate clangd instance for each meson.build file
              -- "meson.build",
              -- I guess we just assume meson options will only be in the root
              "meson_options.txt",
              "build.ninja",
              '.git' }, { path = fname, upward = true })[1])
          end,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            -- "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = false,
            completeUnimported = false,
            clangdFileStatus = true,
          },
        },
        gopls = {},
        pyright = {},
        rust_analyzer = {},
        -- tsserver = {},
        html = { filetypes = { 'html' } },

        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- Ensure the servers above are installed
      local mason_lspconfig = require 'mason-lspconfig'

      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      mason_lspconfig.setup_handlers({
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', capabilities, server.capabilities or {})

          local server_on_attach = server.on_attach

          local on_attach_wrapper = function(i, bufnr)
            on_attach(i, bufnr)
            if server_on_attach then
              server_on_attach(i, bufnr)
            end
          end

          server.on_attach = on_attach_wrapper

          lspconfig[server_name].setup(server)
        end,
      })
    end,
  },
}
