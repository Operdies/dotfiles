vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'

vim.o.termguicolors = true
vim.o.completeopt = 'menuone,noselect'
vim.wo.signcolumn = 'yes'
vim.o.breakindent = true
vim.o.mouse = 'a'
vim.o.compatible = false
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.ruler = true
vim.o.showcmd = true
vim.o.scrolloff = 0
vim.o.incsearch = true
vim.o.backup = false
vim.o.undofile = true
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.textwidth = 0 -- disable automatic text reflowing on long lines
vim.g.termdebug_config = { winbar = 0 }
-- set cino=:0=1sl-2st0
vim.opt.cino = { ":0", "=1s", "l-2s", "t0" }
vim.o.wildmenu = true
vim.opt.wildignore = { "*.o", "*.a" }
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "fuzzy,pum,tagfile"

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.fileencoding = "utf-8" -- the encoding written to a file

vim.opt.relativenumber = false
vim.g.autoformat = false
vim.o.laststatus = 2
vim.o.scrolloff = 3

vim.g.zig_fmt_autosave = 0

