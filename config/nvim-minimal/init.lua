--[[ basic options ]]
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
vim.o.mouse = 'a'
vim.o.compatible = false
-- vim.o.updatetime = 250
-- vim.o.timeoutlen = 300

vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal",
  "localoptions" }
vim.opt.completeopt = { "menu", "menuone", "popup", "noinsert", "fuzzy" }

vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "fuzzy,pum,tagfile"
vim.opt.wildignore = { "*.o", "*.a" }
--]]

--[[ plugins ]]
vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/akinsho/toggleterm.nvim" },
  { src = "https://github.com/wellle/targets.vim" },
})
--]]

--[[ lsp config ]]
local lspconfig = require('lspconfig')
--[[ clangd config ]]
local clangd = {
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
    "--function-arg-placeholders=0",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = false,
    completeUnimported = false,
    clangdFileStatus = true,
  },
}
lspconfig.clangd.setup(clangd)
--]]
vim.lsp.enable({ "lua_ls", "clangd" })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
    end
    vim.keymap.set('n', 'K', vim.lsp.buf.hover)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
    vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float)

    local function toggle_inline_diagnostics()
      local enabled = false
      return function()
        enabled = not enabled
        vim.diagnostic.config({ virtual_text = enabled })
      end
    end
    vim.keymap.set('n', '<leader>cD', toggle_inline_diagnostics())
  end,
})

-- tab completion -- omnicomplete if popup is closed, otherwise next option
vim.keymap.set('i', '<tab>', "pumvisible() == 0 ? '<C-x><C-o>' : '<C-n>'", { expr = true })
-- Open popup if closed, otherwise accept selected option
vim.keymap.set('i', '<C-e>', "pumvisible() == 0 ? '<C-x><C-o>' : '<C-y>'", { expr = true })
-- Abort completion if popup menu is active, otherwise fallback to default <C-a> behavior
vim.keymap.set('i', '<C-a>', "pumvisible() == 0 ? '<C-a>' : '<C-e>'", { expr = true })

--]]

--[[ oil ]]
local function oil_setup()
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
end

oil_setup()
--]]

--[[ pick ]]
local pick = require('mini.pick')
local win_config = function()
  local height = math.floor(0.618 * vim.o.lines)
  local width = math.floor(0.618 * vim.o.columns)
  return {
    anchor = 'NW',
    height = height,
    width = width,
    row = math.floor(0.5 * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end
pick.setup({ window = { config = win_config } })
pick.registry.project = function()
  local projects = vim.fs.dir("$HOME/repos")
  local lst = {}
  for project in projects do
    lst[#lst + 1] = project
  end
  pick.ui_select(lst, {
    prompt = 'Pick a Project',
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      local fullpath = vim.fn.expand("$HOME/repos/" .. choice)
      -- we need to schedule this function because MiniPick refuses
      -- to open the selected file if the new picker is opened inside this handler.
      vim.schedule(function()
        vim.fn.chdir(fullpath)
        pick.builtin.files({ tool = 'git' })
      end)
    end
  end)
end
--]]

--[[ treesitter ]]
require "nvim-treesitter.configs".setup({
  ensure_installed = { "c" },
  highlight = { enable = true }
})
--]]

--[[ keymap ]]
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y') -- yank to system clipboard
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"+d') -- delete to system clipboard
vim.keymap.set('n', '<C-s>', "<cmd>update<cr>")  -- write buffer if it has unsaved changes
vim.keymap.set('n', '<leader>ff', "<cmd>Pick files tool=git<CR>")
vim.keymap.set('n', '<leader>fF', "<cmd>Pick files tool=fd<CR>")
vim.keymap.set('n', '<leader>fg', "<cmd>Pick grep_live<CR>")
vim.keymap.set('n', '<leader>fb', "<cmd>Pick buffers<CR>")
vim.keymap.set('n', '<leader>fr', "<cmd>Pick resume<CR>")
vim.keymap.set('n', '<leader>fp', "<cmd>Pick project<CR>")
vim.keymap.set('n', '<leader>o', "<cmd>Oil<CR>")
vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format)
vim.keymap.set('n', "<leader>bd", "<cmd>bp|bd #<cr>")    -- close current buffer
vim.keymap.set('n', "<esc>", "<esc><cmd>nohlsearch<cr>") -- clear search highlight on escape
vim.keymap.set('n', "gp", "`[v`]")                       -- visually select last paste

vim.keymap.set('n', "<M-j>", "<cmd>m .+1<cr>==")         -- swap current line with next line
vim.keymap.set('n', "<M-k>", "<cmd>m .-2<cr>==")         -- swap current line with previous line

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- create undo points around paste in insert mode
vim.keymap.set('i', '<C-r>"', '<C-G>u<C-r>"<C-G>u')
vim.keymap.set('i', '<C-r>+', '<C-G>u<C-r>+<C-G>u')

vim.keymap.set('i', "<C-d>", "<del>")

-- keep visual selection when 'denting
vim.keymap.set('x', "<", "<gv")
vim.keymap.set('x', ">", ">gv")

vim.keymap.set({ 'n', 'x' }, '<Space>', '<Nop>', { silent = true })

-- double escape: go to normal mode from a terminal
vim.keymap.set("t", "<C-o><C-o>", "<C-\\><C-n>")

-- Side scrolling is annoying
vim.keymap.set({ 'n', 'i', 't', 'v' }, '<ScrollWheelLeft>', '<nop>')
vim.keymap.set({ 'n', 'i', 't', 'v' }, '<ScrollWheelRight>', '<nop>')
--]]

--[[ theming ]]
require "vague".setup({ transparent = true })
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
--]]

--[[ autocommands ]]
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

-- chdir to git root or file if not present (autochdir behavior)
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup("autochdir-to-git-or-file", { clear = true }),
  callback = function()
    local bufpath = vim.fn.expand('%:p')
    if bufpath then
      local err, realpath = pcall(vim.uv.fs_realpath, bufpath)
      if not err then
        local dirname = vim.fs.dirname(realpath)
        local root = vim.fs.root(dirname, ".git")
        vim.fn.chdir(root or dirname)
      end
    end
  end,
})

-- Remember cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup("RestoreLastKnownCursorLine", { clear = true }),
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.fn.execute [[normal! g'"]]
    end
  end,
})
--]]

--[[ toggleterm ]]
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
