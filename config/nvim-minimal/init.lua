--[[ basic options ]]
vim.o.autochdir = false
vim.o.number = true
vim.o.relativenumber = false
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

local is_windows = 'Windows_NT' == vim.loop.os_uname().sysname
local path_separator = is_windows and '\\' or '/'
local home_dir = vim.env.HOME .. path_separator
local git_dir = is_windows and 'C:\\git\\' or home_dir .. "repos/"

--[[ plugins ]]
vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/akinsho/toggleterm.nvim" },
  { src = "https://github.com/wellle/targets.vim" },
  { src = "https://github.com/stevearc/overseer.nvim" },
  { src = "https://github.com/stevearc/dressing.nvim" },
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/seblyng/roslyn.nvim" },
})
--]]

--[[ gitsigns ]]
-- Adds git related signs to the gutter, as well as utilities for managing changes
local gs = require('gitsigns')
local gitsigns_opts = {
  -- See `:help gitsigns.txt`
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local function bufmap(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    bufmap({ 'n', 'v' }, ']c', function()
      if vim.wo.diff then
        return ']c'
      end
      vim.schedule(gs.next_hunk)
      return '<Ignore>'
    end, { expr = true, desc = 'Jump to next hunk' })

    bufmap({ 'n', 'v' }, '[c', function()
      if vim.wo.diff then
        return '[c'
      end
      vim.schedule(gs.prev_hunk)
      return '<Ignore>'
    end, { expr = true, desc = 'Jump to previous hunk' })

    -- Actions
    -- visual mode
    bufmap('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'stage git hunk' })
    bufmap('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'reset git hunk' })
    -- normal mode
    bufmap('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
    bufmap('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
    -- bufmap('n', '<leader>hS', gs.stage_buffer, { desc = 'git stage buffer' })
    bufmap('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
    -- bufmap('n', '<leader>hR', gs.reset_buffer, { desc = 'git reset buffer' })
    -- bufmap('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
    bufmap('n', '<leader>hb', function() gs.blame_line { full = false } end, { desc = 'git blame line' })

    -- Toggles
    bufmap('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
    bufmap('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

    -- Text object
    bufmap({ 'o', 'x' }, 'ah', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
  end
}
gs.setup(gitsigns_opts)
--]]

--[[ lsp config ]]
local lspconfig = require('lspconfig')
--[[ roslyn config ]]
-- prereqs: download roslyn lsp from:
-- setup instructions at https://github.com/seblyng/roslyn.nvim
-- https://dev.azure.com/azure-public/vside/_artifacts/feed/vs-impl/NuGet/Microsoft.CodeAnalysis.LanguageServer.<platform>/overview/5.0.0-2.25451.1
local roslyn_lsp_path = [[C:\tools\Microsoft.CodeAnalysis.LanguageServer.win-x64.5.0.0-2.25451.1\content\LanguageServer\win-x64\Microsoft.CodeAnalysis.LanguageServer.dll]]
local roslyn = {
  on_attach = function()
    print("Roslyn attached!")
  end,
  cmd = {
    "dotnet",
    roslyn_lsp_path,
    "--logLevel", -- this property is required by the server
    "Information",
    "--extensionLogDirectory", -- this property is required by the server
    vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
    "--stdio"
  },
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
  },
}
local function setup_roslyn()
  local roslyn = require('roslyn')

  require('roslyn').setup()
  vim.lsp.config("roslyn", {
    on_attach = function()
      print("Roslyn attached!")
    end,
    cmd = {
      "dotnet",
      lsp_path,
      "--logLevel", -- this property is required by the server
      "Information",
      "--extensionLogDirectory", -- this property is required by the server
      vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
      "--stdio"
    },
    settings = {
      ["csharp|inlay_hints"] = {
        csharp_enable_inlay_hints_for_implicit_object_creation = true,
        csharp_enable_inlay_hints_for_implicit_variable_types = true,
      },
      ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
      },
    },
  })
end
vim.lsp.config("roslyn", roslyn)
-- require('roslyn').setup()
--]]

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
vim.lsp.enable({ "clangd", "roslyn" })
-- vim.lsp.enable({ "lua_ls" })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      local triggers = '_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.>'

      local chars = {}; triggers:gsub(".", function(c) table.insert(chars, c) end)
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
    vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float)
    vim.keymap.set('i', '<C-s>', function() vim.lsp.buf.signature_help({ width = 200, height = 5 }) end )

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

-- Open popup if closed, otherwise accept selected option
vim.keymap.set('i', '<C-e>', "pumvisible() == 0 ? '<C-x><C-o>' : '<C-y>'", { expr = true, silent = true })
-- Abort completion if popup menu is active, otherwise fallback to default <C-a> behavior
vim.keymap.set('i', '<C-a>', "pumvisible() == 0 ? '<C-a>' : '<C-e>'", { expr = true, silent = true })
-- tab completion:
-- snippet jump if snippet is active
-- start omnicomplete if popup is closed
-- pick next completion option if popup is open
vim.keymap.set('i', '<tab>', function()
  if vim.snippet.active({ direction = 1 }) then
    return '<cmd>lua vim.snippet.jump(1)<cr>'
  else
    return '<C-n>'
  end
end, { expr = true })
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

--[[ overseer ]]
local overseer_options = {
  task_list = {
    direction = "bottom",
    min_height = 15,
    default_detail = 2,
    dap = true,
    bindings = {
      ["<C-c>"] = "<cmd>OverseerQuickAction stop<cr>",
      ["<C-r>"] = "<cmd>OverseerQuickAction restart<cr>",
    }
  },
}
require('overseer').setup(overseer_options)
vim.keymap.set('n', '<leader>rt', '<cmd>OverseerRun<cr>')
vim.keymap.set('n', '<leader>rT', function()
  local win = vim.api.nvim_get_current_win()
  vim.cmd('OverseerToggle')
  vim.api.nvim_set_current_win(win)
end)
--]]

--[[ pick ]]

local pick = require('mini.pick')
local pick_options = {
  mappings = {
    choose_marked = '<C-q>',
    scroll_down = '<C-e>',
    scroll_up = '<C-y>',
    refresh = {
      char = '<C-r>',
      func = function ()
        pick.refresh()
      end
    },
  },
  window = {
    config = function()
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
  }
}
pick.setup(pick_options)
pick.registry.project = function()
  local projects = vim.fs.dir(git_dir, { depth = 1 })
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
      local fullpath = vim.fn.expand(git_dir .. choice)
      -- we need to schedule this function because MiniPick refuses
      -- to open the selected file if the new picker is opened inside this handler.
      vim.schedule(function()
        vim.fn.chdir(fullpath)
        pick.builtin.files({ tool = 'git' })
      end)
    end
  end)
end
pick.registry.oldfiles = function()
  local existing = {}
  local added = {}
  local match_func = function(file)
    return file:match('^' .. home_dir) or file:match('^' .. git_dir)
  end
  for _, file in ipairs(vim.v.oldfiles) do
    if match_func(file) then
      if vim.fn.filereadable(file) ~= 0 then
        file = vim.fn.resolve(file)
        if added[file] == nil then
          added[file] = true
          existing[#existing + 1] = { path = file, text = file:gsub('^' .. home_dir, " "):gsub('^' .. git_dir, '󰊢 ') }
        end
      end
    end
  end
  pick.start({ source = { items = existing } })
end

-- Required for lsp pick
require('mini.extra').setup()

--]]

--[[ dressing ]]
require('dressing').setup({ select = { enabled = false }})
vim.ui.select = pick.ui_select
--]]

--[[ treesitter ]]
require "nvim-treesitter.configs".setup({
  ensure_installed = { "c" },
  highlight = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      -- init_selection = 'vx',
      init_selection = 'H',
      node_incremental = 'H',
      scope_incremental = 'K',
      node_decremental = 'L',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,         -- Automatically jump forward to textobj, similar to targets.vim
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
      set_jumps = true,         -- whether to set jumps in the jumplist
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

})
--]]

--[[ keymap ]]
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y') -- yank to system clipboard
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"+d') -- delete to system clipboard
vim.keymap.set('n', '<C-s>', "<cmd>write<cr>")  -- write buffer if it has unsaved changes
vim.keymap.set('n', '<leader>fh', "<cmd>Pick help<CR>")
vim.keymap.set('n', '<leader>ff', "<cmd>Pick files tool=git<CR>")
vim.keymap.set('n', '<leader>fF', "<cmd>Pick files tool=fd<CR>")
vim.keymap.set('n', '<leader>fg', "<cmd>Pick grep_live<CR>")
vim.keymap.set('n', '<leader>cs', "<cmd>Pick lsp scope='document_symbol'<cr>")
vim.keymap.set('n', '<leader>cS', "<cmd>Pick lsp scope='workspace_symbol'<cr>")

vim.keymap.set('n', '<leader>fb', function()
  local pick_buffer_wipeout = function()
    vim.api.nvim_buf_delete(pick.get_picker_matches().current.bufnr, {})
  end
  pick.builtin.buffers(pick_options, { mappings = { wipeout = { char = '<C-w>', func = pick_buffer_wipeout } } })
end)
vim.keymap.set('n', '<leader>fr', "<cmd>Pick oldfiles<CR>")
vim.keymap.set('n', '<leader>fR', "<cmd>Pick resume<CR>")
vim.keymap.set('n', '<leader>fp', "<cmd>Pick project<CR>")
vim.keymap.set('n', '<leader>o', "<cmd>Oil<CR>")
vim.keymap.set({'x','n'}, '<leader>cf', vim.lsp.buf.format)
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

-- Navigate without leaving insert mode
vim.keymap.set('i', "<C-j>", "<Down>")
vim.keymap.set('i', "<C-k>", "<Up>")

-- Shell style navigation in insert and command mode
vim.keymap.set({'i', 'c'}, "<C-h>", "<bs>")
vim.keymap.set({'i', 'c'}, "<C-d>", "<del>")
vim.keymap.set({'i', 'c'}, "<C-b>", "<Left>")
vim.keymap.set({'i', 'c'}, "<C-f>", "<Right>")

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
      local realpath = vim.fn.resolve(bufpath)
      if realpath then
        local dirname = vim.fs.dirname(realpath)
        local root = vim.fs.root(dirname, ".git")
        pcall(vim.fn.chdir, root or dirname)
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
if is_windows then
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
