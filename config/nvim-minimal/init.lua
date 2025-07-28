--[[basic options]]
vim.o.autochdir = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.swapfile = false
vim.o.winborder = "rounded"
vim.g.mapleader = " "
vim.o.undofile = true
vim.g.autoformat = false
vim.o.laststatus = 2
vim.o.scrolloff = 3
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.list = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.mouse = 'a'
vim.o.compatible = false

vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal", "localoptions"  }
vim.opt.completeopt = { "menu", "menuone", "popup", "noselect" }

vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "fuzzy,pum,tagfile"
vim.opt.wildignore = { "*.o", "*.a" }
--]]

--[[plugins]]
vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/akinsho/toggleterm.nvim" },
})
--]]

--[[lsp config]]
vim.lsp.enable({ "lua_ls", "clangd" })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    vim.keymap.set('n', 'K', vim.lsp.buf.hover)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
  end,
})

-- tab completion -- omnicomplete if popup is closed, otherwise next option
vim.keymap.set('i', '<tab>', "pumvisible() == 0 ? '<C-x><C-o>' : '<C-n>'", { expr = true })
-- Open popup if closed, otherwise accept selected option
vim.keymap.set('i', '<C-e>', "pumvisible() == 0 ? '<C-x><C-o><C-n>' : '<C-y>'", { expr = true })
-- Abort completion if popup menu is active, otherwise fallback to default <C-a> behavior
vim.keymap.set('i', '<C-a>', "pumvisible() == 0 ? '<C-a>' : '<C-e>'", { expr = true })

--]]

--[[oil]]
require "oil".setup()
--]]

--[[pick]]
require "mini.pick".setup()
--]]

--[[treesitter]]
require "nvim-treesitter.configs".setup({
  ensure_installed = { "c" },
  highlight = { enable = true }
})
--]]

--[[keymap]]
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y') -- yank to system clipboard
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>d', '"+d') -- delete to system clipboard
vim.keymap.set('n', '<C-s>', "<cmd>update<cr>") -- write buffer if it has unsaved changes
vim.keymap.set('n', '<leader>ff', "<cmd>Pick files<CR>")
vim.keymap.set('n', '<leader>fg', "<cmd>Pick grep_live<CR>")
vim.keymap.set('n', '<leader>fb', "<cmd>Pick buffers<CR>")
vim.keymap.set('n', '<leader>fr', "<cmd>Pick resume<CR>")
vim.keymap.set('n', '<leader>o', "<cmd>Oil<CR>")
vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format)
vim.keymap.set('n', "<leader>bd", "<cmd>bp|bd #<cr>") -- close current buffer
vim.keymap.set('n', "<esc>", "<esc><cmd>nohlsearch<cr>") -- clear search highlight on escape
vim.keymap.set('n', "gp", "`[v`]") -- visually select last paste

vim.keymap.set('n', "<M-j>", "<cmd>m .+1<cr>==") -- swap current line with next line
vim.keymap.set('n', "<M-k>", "<cmd>m .-2<cr>==") -- swap current line with previous line

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- create undo points around paste in insert mode
vim.keymap.set('i', '<C-r>"', '<C-G>u<C-r>"<C-G>u')
vim.keymap.set('i', '<C-r>+', '<C-G>u<C-r>+<C-G>u')

vim.keymap.set('i', "<C-d>", "<del>")

-- keep visual selection when 'denting
vim.keymap.set('v', "<", "<gv")
vim.keymap.set('v', ">", ">gv")

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- double escape: go to normal mode from a terminal
vim.keymap.set("t", "<C-o><C-o>", "<C-\\><C-n>")

-- Side scrolling is annoying
vim.keymap.set({'n', 'i', 't', 'v'}, '<ScrollWheelLeft>' , '<nop>')
vim.keymap.set({'n', 'i', 't', 'v'}, '<ScrollWheelRight>' , '<nop>')
--]]

--[[theming]]
require "vague".setup({ transparent = true })
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
--]]

--[[autocommands]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Treat C# files as xml
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup("XmlIndent", { clear = true }),
  pattern = { "*.csproj", "*.props", "*.targets" },
  callback = function()
    vim.opt_local.filetype = "xml"
    vim.opt_local.shiftwidth = 4
  end,
})

-- Remember cursor position
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup("XmlIndent", { clear = true }),
  pattern = { "*.csproj", "*.props", "*.targets" },
  callback = function()
    vim.opt_local.filetype = "xml"
    vim.opt_local.shiftwidth = 4
  end,
})
--]]

--[[toggleterm]]
if 'Windows_NT' == vim.loop.os_uname().sysname then
  vim.cmd [[
  let &shell = 'pwsh'
  let &shellcmdflag = '-NoLogo -Command'
  " let &shellcmdflag = '-NoLogo -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
  let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  let &shellpipe  = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
  set shellquote= shellxquote=
  ]]
end

require('toggleterm').setup({
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
  shell = vim.o.shell,
})
local lazygit = require("toggleterm.terminal").Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  on_open = function(term)
    vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-q>", '<cmd>close<cr>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-'>", '<cmd>close<cr>', { noremap = true, silent = true })
  end,
})
vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "lazygit" })
--]]

-- vim: foldmethod=marker foldmarker=--[[,--]]
