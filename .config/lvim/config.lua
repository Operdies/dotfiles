--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = false
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
  },
  -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
  },
}

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
-- }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dap.active = true
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"

if (lvim.builtin.nvimtree.show_icons) then
  lvim.builtin.nvimtree.show_icons.git = 0
end

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "c_sharp",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skiipped for the current filetype
-- vim.tbl_map(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "black", filetypes = { "python" } },
--   { command = "isort", filetypes = { "python" } },
--   {
--     -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "prettier",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--print-with", "100" },
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "shellcheck",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--severity", "warning" },
--   },
--   {
--     command = "codespell",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "python" },
--   },
-- }

-- Additional Plugins
lvim.plugins = {
  { "mfussenegger/nvim-dap" },
  {
    "jbyuki/one-small-step-for-vimkind",
    requires = { { "mfussenegger/nvim-dap" } },
  },
  -- { "chaoren/vim-wordmotion" },
  { "folke/tokyonight.nvim" },
  { "svermeulen/vimpeccable" },
  { "skywind3000/asyncrun.vim" },
  {
    "phaazon/hop.nvim",
    as = "hop",
    config = function() require 'hop'.setup() end,
  },

  -- {
  --   "folke/trouble.nvim",
  --   cmd = "TroubleToggle",
  -- },
}


-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.json", "*.jsonc" },
--   -- enable wrap mode for json files only
--   command = "setlocal wrap",
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })

-- Debugging


local dap = require('dap')
-- lvim.builtin.dap.on_config_done = function(dap)
dap.adapters.netcoredbg = {
  name = "netcoredbg",
  type = 'executable',
  command = '/usr/bin/netcoredbg',
  args = { '--interpreter=vscode' },
}
dap.configurations.c_sharp = {
  {
    name = "Launch - netcoredbg",
    type = "netcoredbg",
    request = "launch",
    program = "${workspaceFolder}/bin/Debug/tap.dll",
    cwd = "${workspaceFolder}/bin/Debug",
    stopOnEntry = false,
    -- args = { 'package', 'install', 'TUI', '-v', '--version', 'any', '-t', '/usr/share/OpenTAP' },
    args = { 'completion', 'regenerate' },
    runInTerminal = false,
  },
  {
    type = "netcoredbg",
    name = "attach - netcoredbg",
    request = "attach",
    processId = require('dap.utils').pick_process,
  },

}
dap.configurations.cs = dap.configurations.c_sharp
local widgets = require('dap.ui.widgets')
local my_dap_sidebar = widgets.sidebar(widgets.scopes)
-- end

-- Neat bindings
local vimp = require('vimp')
-- unmap vimp bindings so the config can be reloaded
vimp.unmap_all()

local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

-- Add line above
map("n", "[<space>", "moO<esc>`o", opts)
-- Add line below
map("n", "]<space>", "moo<esc>`o", opts)
map("n", "<Down>", ":DapStepOver<cr>", { noremap = false, silent = true })
map("n", "<Left>", ":DapStepOut<cr>", { noremap = false, silent = true })
map("n", "<Right>", ":DapStepInto<cr>", { noremap = false, silent = true })
map("n", "<Up>", ":DapContinue<cr>", { noremap = false, silent = true })


-- configure hop
require 'hop'.setup()

map("n", "gw", "<cmd>HopWord<cr>", opts)
map("n", "gL", "<cmd>HopLine<cr>", opts)
map("n", "gF", "<cmd>HopChar1<cr>", opts)
map("n", "g/", "<cmd>HopPattern<cr>", opts)


-- Debugger mappings
-- map("n", ",h", ":DapStepOut<cr>", opts);
-- map("n", ",l", ":DapStepInto<cr>", opts)
-- map("n", ",j", ":DapStepOver<cr>", opts)
-- map("n", ",c", ":DapContinue<cr>", opts)
-- map("n", ",t", ":DapToggleBreakpoint<cr>", opts)
-- map("n", ",s", ":DapTerminate<cr>", opts)
lvim.builtin.which_key.mappings["dk"] = { "<cmd>lua require('dap.ui.widgets').hover()<cr>", "Hover" }
vimp.nnoremap(",o", my_dap_sidebar.toggle)


-- Colorscheme
vim.g.tokyonight_style = 'storm'
lvim.colorscheme = "tokyonight"
