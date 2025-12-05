-- Disable Builtin Plugins {{{1

-- this probably affects startup time ?
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1

-- Basic Options {{{1
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
vim.o.scrolloff = 3
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.list = true
vim.o.mouse = 'a'
vim.o.compatible = false
vim.o.ruler = false
vim.o.cmdheight = 1
vim.o.laststatus = 2
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'
-- vim.o.updatetime = 250
-- vim.o.timeoutlen = 300

vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal",
  "localoptions" }
vim.opt.completeopt = { "menu", "menuone", "popup", "noinsert", "noselect", "fuzzy" }

vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "fuzzy,pum,tagfile"
vim.opt.wildignore = { "*.o", "*.a" }

vim.o.pumblend = 10
vim.o.winblend = 10

-- hides (partial) commands in the cmd windows.
-- Unfortunately, this also hides information about visual selections.
-- We avoid this by enabling it in visual mode, and disabling it otherwise.
vim.o.showcmd = false

-- treat .h files as c files. Default is cpp
vim.g.c_syntax_for_h = "c"

-- OS specific settings {{{1
local is_windows = 'Windows_NT' == vim.loop.os_uname().sysname
local is_osx = 'Darwin' == vim.loop.os_uname().sysname
local path_separator = is_windows and '\\' or '/'
local home_dir = vim.fn.resolve(vim.env.HOME) .. path_separator
local git_dir = is_windows and [[C:\git\]] or home_dir .. "repos/"
local tools_dir = is_windows and [[C:\tools\]] or home_dir .. "tools/"
local config_dir = (is_windows and home_dir .. [[AppData\Local\]]) or (home_dir .. ".config/")
local os = (is_windows and "windows") or (is_osx and "osx") or "linux"

-- Helper functions {{{1
local function rpad(str, len, char)
  if char == nil then char = ' ' end
  local width = vim.fn.strwidth(str)
  return string.rep(char, len - width) .. str
end
local function lpad(str, len, char)
  if char == nil then char = ' ' end
  local width = vim.fn.strwidth(str)
  return str .. string.rep(char, len - width)
end
local function friendly_path(file)
  return file:gsub('^' .. git_dir, '󰊢 '):gsub('^' .. home_dir, " ")
end


-- Plugins {{{1
vim.pack.add({
  -- file browser
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  -- lightweight telescope alternative (with minor patch by me)
  { src = "https://github.com/nvim-mini/mini.pick" },
  -- more text objects
  { src = "https://github.com/echasnovski/mini.ai" },
  -- multiline and repeatable fFtT
  { src = "https://github.com/echasnovski/mini.jump" },
  -- provides parsers for most languages
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  -- provides additional functions for manipulating syntax elements
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
  -- default configurations for most language servers
  { src = "https://github.com/neovim/nvim-lspconfig" },
  -- floating terminal
  { src = "https://github.com/akinsho/toggleterm.nvim" },
  -- incredible task runner
  { src = "https://github.com/stevearc/overseer.nvim" },
  -- vim.ui / vim.input replacement
  { src = "https://github.com/stevearc/dressing.nvim" },
  -- git operations
  { src = "https://github.com/tpope/vim-fugitive" },
  -- more git operations
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  -- C# lsp
  { src = "https://github.com/seblyng/roslyn.nvim" },
  -- Debugging adapter
  { src = "https://github.com/mfussenegger/nvim-dap" },
  -- Debugging UI
  -- { src = "https://github.com/igorlfs/nvim-dap-view" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  -- nio -- asynchronous io. Dependency of nvim-dap-ui
  { src = "https://github.com/nvim-neotest/nvim-nio" },
})

-- Theming {{{1

local function my_colorscheme()
  vim.pack.add({'https://github.com/tjdevries/colorbuddy.nvim'})
  local colorbuddy = require('colorbuddy')
  colorbuddy.colorscheme("my-colorscheme")
  local Color = colorbuddy.Color
  local Group = colorbuddy.Group
  local c = colorbuddy.colors
  local g = colorbuddy.groups
  local s = colorbuddy.styles

  local palettes = {
    catppuccin_mocha = {
      Rosewater = '#f5e0dc',
      Flamingo  = '#f2cdcd',
      Pink      = '#f5c2e7',
      Mauve     = '#cba6f7',
      Red       = '#f38ba8',
      Maroon    = '#eba0ac',
      Peach     = '#fab387',
      Yellow    = '#f9e2af',
      Green     = '#a6e3a1',
      Teal      = '#94e2d5',
      Sky       = '#89dceb',
      Sapphire  = '#74c7ec',
      Blue      = '#89b4fa',
      Lavender  = '#b4befe',
      Text      = '#cdd6f4',
      Subtext1  = '#bac2de',
      Subtext0  = '#a6adc8',
      Overlay2  = '#9399b2',
      Overlay1  = '#7f849c',
      Overlay0  = '#6c7086',
      Surface2  = '#585b70',
      Surface1  = '#45475a',
      Surface0  = '#313244',
      Base      = '#1e1e2e',
      Mantle    = '#181825',
      Crust     = '#11111b',
    }
  }

  local palette = palettes.catppuccin_mocha

  for name, color in pairs(palette) do
    Color.new(name, color)
  end


  -- styles: bold, underline, undercurl, strikethrough, reverse, inverse, italic, standout, nocombine, none, 
  --                                                             ~~~~~~~ <- not working

  -- get all highlight groups and colors:
  -- lua print(vim.inspect(vim.api.nvim_get_hl(0, {})))

  Group.new("Normal", c.Text, c.Base)

  Group.new("MatchParen", c.Text, c.Surface1, s.bold)

  -- the search term under the cursor
  Group.new("CurSearch",  c.Base, c.Pink:dark(),    s.bold)
  -- the search option which will be jumped to if a search is executed
  Group.new("IncSearch",  c.Base, c.Pink:dark(),    s.bold)
  -- the highlight color of the current hlsearch
  Group.new("Search",     c.Base, c.Pink,    s.none)
  -- the highlight color of a :s/a/b operation
  Group.new("Substitute", c.Base, c.Pink,   s.none)

  -- Floating windows (mostly mini pick)
  Group.new('FloatBorder', c.Lavender, c.Mantle, s.none)
  Group.new('FloatTitle', c.Lavender, c.Mantle, s.none)
  Group.new('FloatFooter', c.Lavender, c.Mantle, s.none)
  Group.new('NormalFloat', c.Lavender, c.Mantle, s.none)

  -- Diagnostic colors -- these colors are also used by Mini.Pick
  Group.new('DiagnosticFloatingHint', c.Lavender, nil, s.none)
  Group.new('DiagnosticFloatingInfo', c.Blue, nil, s.none)
  Group.new('DiagnosticFloatingWarn', c.Peach, nil, s.none)
  Group.new('DiagnosticFloatingError', c.Red, nil, s.none)

  -- Any special symbol (??)
  Group.new("Special", c.Mauve, nil, s.none)

  -- popup menu styling
  Group.new("PMenu",      c.Lavender, c.Surface0, s.none)
  Group.new("PMenuSel",   nil,        c.Surface1, s.none)
  Group.new("PMenuThumb", nil,        c.Lavender, s.none)
  Group.new("PMenuSBar",  nil,        c.Surface0, s.none)

  -- Cursorline is linked by MiniPick as well. Since this is used
  -- for selection, keep this next to QuickFix config to keep consistent styling
  Group.new("CursorLine",   nil,        c.Surface1, s.none)
  Group.new("QuickFixLine", nil,        c.Surface1, s.bold)
  Group.new("qffilename",   c.Lavender, nil,        s.none)

  Group.new("Visual", nil, c.Surface1, s.none)
  Group.new("Folded", c.Lavender, c.Surface0, s.bold)
  Group.new("Directory", c.Blue, nil, s.bold)

  -- status line
  Group.new("StatusLine", c.Text, c.Mantle, s.bold)
  Group.new("StatusLineNC", c.Surface2, c.Mantle, s.none)

  -- hide filler symbol '~' at end of buffer by setting fg=bg
  Group.new("EndOfBuffer", c.Base, c.Base, s.none)
  Group.new("LineNr", c.Overlay1, c.Base, s.none)
  Group.new("WinSeparator", c.Overlay0, nil, s.none)
  Group.new("Delimiter", c.Overlay0, nil, s.none)

  -- msg area
  Group.new("MsgArea", c.Text, c.Base, s.none)
  Group.new("ModeMsg", c.Lavender, nil, s.none)

  -- e.g. escaped characters or raw bytes in a string (\x1b, \0)
  Group.new("SpecialChar", c.Red, nil, s.none)

  Group.new("@comment", c.Subtext0, nil, s.none)
  Group.new("Comment", c.Subtext0, nil, s.none)
  Group.new("@boolean", c.Peach, nil, s.none)
  Group.new("@constant", c.Peach, nil, s.none)
  Group.new("@constant.builtin", c.Red, nil, s.none)
  Group.new("@constructor", c.Maroon, nil)
  Group.new("@function", c.Yellow, nil, nil)
  Group.new("@function.builtin", c.Red, nil, s.none)
  Group.new("@function.call", c.Blue, nil, nil)
  Group.new("@function.method.call", c.Blue, nil, nil)
  Group.new("@keyword", c.Lavender, nil, s.none)
  Group.new("@keyword.faded", c.Lavender:light(), nil, s.none)
  Group.new("@punctuation", c.Text, nil)
  Group.new("@string", c.Green, nil, s.none)
  Group.new("@lsp.type.namespace", c.Blue, nil, s.none)
  Group.new("@type", c.Mauve, nil, s.none)
  Group.new("@type.builtin", c.Mauve, nil, s.none)
  Group.new("Type", c.Mauve, nil, s.none)
  Group.new("@module", c.Yellow, nil, s.none)

  Group.new("@tag.html", c.Blue, nil, s.none)
  Group.new("@tag.delimiter.html", c.Lavender, nil, s.none)
  Group.new("@tag.attribute.html", c.Red, nil, s.none)

  Group.new("@tag.xml", c.Blue, nil, s.none)
  Group.new("@tag.delimiter.xml", c.Lavender, nil, s.none)
  Group.new("@tag.attribute.xml", c.Red, nil, s.none)

  -- Markdown, man pages probably
  Group.new("Keyword", c.Mauve, nil, s.none)
  Group.new("Title",                            c.Blue,   nil, s.bold)
  -- Markdown
  Group.new("@markup.link.label",               c.Peach, nil, s.bold)
  Group.new("@markup.link",                     c.Text,   nil, s.none)
  Group.new("@markup.link.url.markdown_inline", c.Blue,    nil, s.underline)

  -- yaml
  Group.new("@property.yaml", c.Lavender, nil, s.none)

  -- diffs
  Group.new('diffFile',      c.Subtext2, nil, s.none)
  Group.new('gitdiff',       c.Subtext1, nil, s.none)
  Group.new('diffNoEOL',     c.Subtext0, nil, s.none)
  Group.new('diffIndexLine', c.Subtext0, nil, s.none)
  Group.new('diffSubName',   c.Mauve,    nil, s.none)
  Group.new('diffLine',      c.Sapphire, nil, s.none)
  Group.new('diffremoved',   c.Red,      nil, s.none)
  Group.new('diffadded',     c.Green,    nil, s.none)
  Group.new('diffNewFile',   c.Green,    nil, s.none)
  Group.new('diffOldFile',   c.Red,      nil, s.none)

end

my_colorscheme()

-- mini.align -- text alignment {{{1
vim.pack.add({"https://github.com/nvim-mini/mini.align"})
require('mini.align').setup()

-- mini.ai {{{1
require('mini.ai').setup()

-- mini.hipatterns {{{1
local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
    hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
    todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
    note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
vim.keymap.set('n', '<leader>ft', function () require('mini.extra').pickers.hipatterns({ scope = 'all'}) end)


-- gitsigns {{{1
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

-- oil {{{1
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

-- overseer {{{1
local overseer_options = {
  task_list = {
    direction = "bottom",
    min_height = 15,
    dap = true
  },
}
require('overseer').setup(overseer_options)
vim.keymap.set('n', '<leader>rt', '<cmd>OverseerRun<cr>')
vim.keymap.set('n', '<leader>rT', function()
  local win = vim.api.nvim_get_current_win()
  vim.cmd('OverseerToggle')
  vim.api.nvim_set_current_win(win)
end)

-- quicker {{{1
vim.pack.add({ "https://github.com/stevearc/quicker.nvim" })
require('quicker').setup(
  { 
    follow = { enabled = false }, 
    edit = { enabled = true, autosave = "unmodified" },
    trim_leading_whitespace = 'all',
    highlight = { treesitter = true, lsp = true, load_buffers = false },
  }
)

-- Mini.Jump {{{1
require('mini.jump').setup({})
-- Mini.Pick {{{1

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

-- Pick Project {{{2
pick.registry.project = function()
  local projects = vim.fs.dir(git_dir, { depth = 1 })
  local lst = {}
  for project in projects do
    local project_dir = vim.fs.joinpath(git_dir, project)
    local git_dir = vim.fs.joinpath(project_dir, ".git")
    if vim.fn.isdirectory(git_dir) == 1 then
      lst[#lst + 1] = { name = project, dir = project_dir }
    end
  end
  pick.ui_select(lst, {
    prompt = 'Pick a Project',
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      -- open the project directory in an oil buffer
      vim.cmd("edit " .. choice.dir)
      -- change work directories to allow grep/find actions from this directory
      vim.cmd("cd " .. choice.dir)
    end
  end)
end

-- Pick OldFiles {{{2
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
          existing[#existing + 1] = { path = file, text = friendly_path(file) }
        end
      end
    end
  end
  pick.start({ source = { items = existing, name = "Old Files" } })
end

-- Pick Changelist {{{2

-- navigate the change list
pick.registry.pick_changelist = function()
  local changelist = vim.fn.getchangelist()
  local changes = changelist[1]
  local position = changelist[2]
  local position_index = 0

  local items = {}
  for i, change in ipairs(changes) do 
    local bufnr = vim.fn.bufnr()
    local bufname = vim.fn.bufname(bufnr)
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, change.lnum - 1, change.lnum, true)
    local text = bufname
    if ok and lines[1] then 
      text = lines[1]
    end
    local offset = position - i + 1
    local where = "" .. change.lnum
    items[#items + 1] = { path = bufname, lnum = change.lnum, col = change.col, text = text, offset = offset, where = where }
  end

  for i = 1, #items/2, 1 do
    items[i], items[#items-i+1] = items[#items-i+1], items[i]
  end

  local columns = { 0, 0 }
  for i, item in ipairs(items) do
    if item.offset == 0 then position_index = i end
    local index = "" .. item.offset
    local i_width = vim.fn.strwidth(index)
    if columns[1] < i_width then columns[1] = i_width end
    local path = item.where
    local p_width = vim.fn.strwidth(path)
    if columns[2] < p_width then columns[2] = p_width end
  end

  for _, item in ipairs(items) do
    item.text = rpad("" .. item.offset, columns[1], " ") .. " │ " .. lpad(item.where, columns[2], " ") .. " │ " .. item.text
  end

  local choice = function(item)
    if item.offset == 0 then return end
    vim.api.nvim_win_call(pick.get_picker_state().windows.target,
      function()
        if item.offset == 0 then
          vim.cmd("normal! " .. item.lnum .. 'gg' .. item.col .. '|')
          return
        end
        local old = 'g;'
        local new = 'g,'
        local dir = old
        if item.offset < 0 then dir = new end
        local cmd = item.offset .. dir
        vim.cmd("normal! " .. cmd)
      end)
  end

  -- I was not able to find a good way to set the default picker index,
  -- so instead we define a custom 'show' function which sets the index 
  -- the first time it is called.
  local did_set = false
  local pick_set_index_hack = function(buf, items, query)
    if position_index > 0 and not did_set then
      did_set = true 
      local m = pick.get_picker_matches()
      local indices = m.all_inds
      pick.set_picker_match_inds({indices[position_index]}, "current")
    end
    local lines = vim.tbl_map(function(x) return x.text end, items)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  local opts = {
    options = { content_from_bottom = false },
    source = { name = "Change", items = items, choose = choice, show = pick_set_index_hack } 
  }
  pick.start(opts)
end

-- Pick Jumplist {{{2

-- navigate the jump list
pick.registry.pick_jumplist = function()
  local jumplist = vim.fn.getjumplist()
  local jumps = jumplist[1]
  local position = jumplist[2]
  local position_index = 0

  local items = {}
  for i, jump in ipairs(jumps) do 
    if vim.fn.bufexists(jump.bufnr) then
      local bufname = vim.fn.bufname(jump.bufnr)
      if bufname and bufname ~= "" then
        local ok, lines = pcall(vim.api.nvim_buf_get_lines, jump.bufnr, jump.lnum - 1, jump.lnum, true)
        local text = bufname
        if ok and lines[1] then 
          text = lines[1]
        end
        local offset = position - i + 1
        local where = friendly_path(bufname) .. ":" .. jump.lnum
        local maxlen = 50
        if #where > maxlen then
          local cutoff = maxlen
          for i = 0, maxlen do
            -- break on first non-continuation character
            -- this check is really lazy and will really fail all utf8 characters, but it's good enough
            local index = #where - maxlen + i
            local chr = where:sub(index, index)
            -- print(vim.inspect({ path = where, iteration = i, index = index, char = chr }))
            -- print(chr)
            if string.byte(chr) < 128 then
              cutoff = index
              break
            end
          end
          where = "…" .. where:sub(cutoff) 
        end
        items[#items + 1] = { path = bufname, lnum = jump.lnum, col = jump.col, text = text, offset = offset, where = where, bufnr = jump.bufnr }
      end
    end
  end

  for i = 1, #items/2, 1 do
    items[i], items[#items-i+1] = items[#items-i+1], items[i]
  end

  local columns = { 0, 0 }
  for i, item in ipairs(items) do
    if item.offset == 0 then position_index = i end
    local index = "" .. item.offset
    local i_width = vim.fn.strwidth(index)
    if columns[1] < i_width then columns[1] = i_width end
    local path = item.where
    local p_width = vim.fn.strwidth(path)
    if columns[2] < p_width then columns[2] = p_width end
  end

  for _, item in ipairs(items) do
    item.text = rpad("" .. item.offset, columns[1], " ") .. " │ " .. lpad(item.where, columns[2], " ") .. " │ " .. item.text
  end

  local choice = function(item)
    vim.api.nvim_win_call(pick.get_picker_state().windows.target,
      function()
        if item.offset == 0 then 
          vim.api.nvim_win_set_buf(0, item.bufnr)
          vim.cmd("normal! " .. item.lnum .. 'gg' .. item.col .. '|')
          return 
        end

        local old = string.char(string.byte('O') - 64)
        local new = string.char(string.byte('I') - 64)
        local dir = old
        if item.offset < 0 then dir = new end
        local cmd = item.offset .. dir
        vim.cmd("normal! " .. cmd)
      end)
  end

  -- I was not able to find a good way to set the default picker index,
  -- so instead we define a custom 'show' function which sets the index 
  -- the first time it is called.
  local did_set = false
  local pick_set_index_hack = function(buf, items, query)
    if position_index > 0 and not did_set then
      did_set = true 
      local m = pick.get_picker_matches()
      local indices = m.all_inds
      pick.set_picker_match_inds({indices[position_index]}, "current")
    end
    local lines = vim.tbl_map(function(x) return x.text end, items)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  local opts = {
    options = { content_from_bottom = false },
    source = { name = "Jump", items = items, choose = choice, show = pick_set_index_hack } 
  }
  pick.start(opts)
end

-- Required for lsp pick
require('mini.extra').setup()


-- Dressing {{{1
require('dressing').setup({ select = { enabled = false }})
vim.ui.select = pick.ui_select

-- Treesitter {{{1
require("nvim-treesitter.configs").setup({
  ensure_installed = { "bash", "c", "c_sharp", "html", "javascript", "json", "make", "xml", "yaml", },
  indent = { enable = true, disable = { --[[ see :help nvim-treesitter-indentation-mod ]] }},
  highlight = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
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

-- LSP {{{1
vim.lsp.set_log_level(vim.log.levels.OFF)
vim.diagnostic.config({ 
  signs = false, -- I prefer dedicating the gutter to gitsigns. Diagnostics are distracting here.
  virtual_text = { severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN } },
})
-- roslyn config {{{2
-- prereqs: download roslyn lsp from:
-- setup instructions at https://github.com/seblyng/roslyn.nvim
-- https://dev.azure.com/azure-public/vside/_artifacts/feed/vs-impl/NuGet/Microsoft.CodeAnalysis.LanguageServer.<platform>/overview/5.0.0-2.25451.1
local platform = is_windows and 'win-x64' or 'linux-x64'
local roslyn_lsp_path = vim.fs.joinpath(tools_dir, 'roslyn-lsp', 'Microsoft.CodeAnalysis.LanguageServer.dll')
if vim.fn.filereadable(roslyn_lsp_path) ~= 0 then
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
  vim.lsp.config("roslyn", roslyn)
  vim.lsp.enable({ "roslyn" })
end
-- require('roslyn').setup()

-- clangd config {{{2
vim.lsp.config('clangd', {
  on_attach = function(_, bufnr)
    -- Stolen from:
    -- https://github.com/neovim/nvim-lspconfig/blob/07f4e93de92e8d4ea7ab99602e3a8c9ac0fb778a/lua/lspconfig/configs/clangd.lua#L11
    local function switch_source_header(bufnr)
      local method_name = 'textDocument/switchSourceHeader'
      local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
      if not client then
        return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
      end
      local params = vim.lsp.util.make_text_document_params(bufnr)
      client.request(method_name, params, function(err, result)
        if err then
          error(tostring(err))
        end
        if not result then
          vim.notify('corresponding file cannot be determined')
          return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
      end, bufnr)
    end

    vim.keymap.set("n", "<leader>ch", function() switch_source_header(bufnr) end,
      { buffer = bufnr, desc = "Switch Source/Header" })
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
})
vim.lsp.enable({ "clangd" })

-- "deprecated" bindings. Used for keybinds I would like to stop using
local prefer = function(preferred)
  return function()
    print("Prefer " .. preferred .. " instead.")
  end
end

-- vim.lsp.enable({ "lua_ls" })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local function bufmap(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      local triggers = '_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.>'

      local chars = {}; triggers:gsub(".", function(c) table.insert(chars, c) end)
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    bufmap('n', 'gd', vim.lsp.buf.definition)
    bufmap('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
    bufmap('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
    bufmap('n', '<leader>cd', prefer("<C-w>d"))
    bufmap('i', '<C-s>', function() vim.lsp.buf.signature_help({ width = 200, height = 5 }) end )
  end,
})

-- set undo point before inserting text
vim.keymap.set('i', '<C-a>', '<C-G>u<C-a><C-G>u', { silent = true, noremap = true })

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

-- Keybindings {{{1
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y') -- yank to system clipboard
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"+d') -- delete to system clipboard
vim.keymap.set('n', '<C-s>', "<cmd>write<cr>")  -- write buffer if it has unsaved changes
vim.keymap.set('n', '<leader>fh', "<cmd>Pick help<CR>")
vim.keymap.set('n', '<leader>ff', function() require('mini.pick').builtin.files({ tool = "fd" }, nil) end)
vim.keymap.set('n', 'gff', function() require('mini.pick').builtin.files({ tool = "git" }, nil) end)
vim.keymap.set('n', '<leader>fg', "<cmd>Pick grep_live<CR>")
vim.keymap.set('n', '<leader>cs', "<cmd>Pick lsp scope='document_symbol'<cr>")
vim.keymap.set('n', 'gfj', "<cmd>Pick pick_jumplist<CR>")
vim.keymap.set('n', 'gf;', "<cmd>Pick pick_changelist<CR>")
vim.keymap.set('n', '[t', '<cmd>tabp<cr>')
vim.keymap.set('n', ']t', '<cmd>tabn<cr>')

-- TODO: Create custom picker so support cycling severity modes with e.g. <C-a> / <C-x>
-- TODO: The 'all' option seems to only include open buffers. Custom implementation should include everything returned by `vim.diagnostic.get()`
-- TODO: Add hotkey for cycling between current buffer / all buffers (tab?)
local pick_diagnostics = require('mini.extra').pickers.diagnostic
vim.keymap.set('n', 'gfd', function() 
  pick_diagnostics({
    scope = "current", 
    sort_by = "severity",
    get_opts = { severity = vim.diagnostic.severity.ERROR },
  }) end)
vim.keymap.set('n', 'gfw', function() 
  pick_diagnostics({
    scope = "current", 
    sort_by = "severity",
    get_opts = { severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR } },
  }) end)
vim.keymap.set('n', 'gfD', function() 
  pick_diagnostics({ 
    scope = "all", 
    sort_by = "path",
    get_opts = { severity = vim.diagnostic.severity.ERROR },
  }) end)

-- TODO: according to the documentation, calling vim.lsp.buf.workspace_symbol()
-- without an argument should return all symbols in the workspace, but this is 
-- not the case for roslyn at least (did not check others).
-- Figure out if there is a workaround for this.
vim.keymap.set('n', '<leader>cS', "<cmd>Pick lsp scope='workspace_symbol'<cr>")
vim.keymap.set('n', 'grR', "<cmd>Pick lsp scope='references'<cr>")

vim.keymap.set('n', '<leader>fb', function()
  local pick_buffer_wipeout = function()
    local m = pick.get_picker_matches()
    local indices = m.all_inds
    local rm_idx = 0

    -- Find the index of the selected item
    for i, v in ipairs(indices) do
      if v == m.current_ind then
        rm_idx = i
        break
      end
    end

    -- close the buffer of the selected item
    vim.api.nvim_buf_delete(m.current.bufnr, { force = true })

    -- remove the deleted buffer from the list of matches
    table.remove(indices, rm_idx)

    -- If the deleted item was the last element in the list,
    -- the next selected element should be the previous element
    if rm_idx > #indices then rm_idx = rm_idx - 1 end

    pick.set_picker_match_inds(indices, "all")
    if rm_idx > 0 then
      pick.set_picker_match_inds({indices[rm_idx]}, "current")
    end
  end
  pick.builtin.buffers(pick_options, { mappings = { wipeout = { char = '<C-w>', func = pick_buffer_wipeout } } })
end)

vim.keymap.set('n', '<leader>fr', "<cmd>Pick oldfiles<CR>")
vim.keymap.set('n', '<leader>fR', "<cmd>Pick resume<CR>")
vim.keymap.set('n', '<leader>fp', "<cmd>Pick project<CR>")
vim.keymap.set('n', "<leader>f'", "<cmd>Pick registers<CR>")

vim.keymap.set('n', '<leader>o', "<cmd>Oil<CR>")
-- TODO: Get out of the habit of formatting code!
-- vim.keymap.set({'x','n'}, '<leader>cf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>cf', prefer("formatting ranges"))
vim.keymap.set('x', '<leader>cf', vim.lsp.buf.format)
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

-- Autocommands {{{1

local augroup = vim.api.nvim_create_augroup('personal-autocommands', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = augroup,
  pattern = '*',
})

-- Treat C# files as xml
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  pattern = { "*.csproj", "*.props", "*.targets", "*.xaml" },
  callback = function()
    vim.opt_local.filetype = "xml"
    vim.opt_local.shiftwidth = 4
  end,
})

-- Increase shiftwidth in .cs files
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  pattern = { "*.csproj", "*.props", "*.targets", "*.cs" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.makeprg = "dotnet build -c Debug"
  end,
})

-- chdir to git root or file if not present (autochdir behavior)
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
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
  group = augroup,
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.fn.execute [[normal! g'"]]
      -- open folds under the cursor.
      -- note that this is scheduled because folds are not applied during BufReadPost,
      -- but they appear to be applied after the next schedule()
      -- use pcall() to suppress errors when no folds were found
      vim.schedule(function() pcall(vim.cmd, "foldopen!") end)
    end
  end,
})

-- map gso to source current file in init.lua
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  pattern = { "init.lua" },
  callback = function()
    vim.keymap.set('n', 'gso', '<cmd>update<cr><cmd>so<cr>', { buffer = vim.fn.bufnr() })
  end,
})

-- set showcmd based on the current mode
vim.api.nvim_create_autocmd('ModeChanged', {
  group = augroup,
  callback = function()
    local mode = vim.fn.mode()
    local showcmd = 
    {
      -- all visual mode strings. See :help mode()
      ['v']       = true, -- Visual by character
      ['vs']      = true, -- Visual by character using |v_CTRL-O| in Select mode
      ['V']       = true, -- Visual by line
      ['Vs']      = true, -- Visual by line using |v_CTRL-O| in Select mode
      ['CTRL-V']  = true, -- Visual blockwise
      ['CTRL-Vs'] = true, -- Visual blockwise using |v_CTRL-O| in Select mode
    }
    vim.o.showcmd = (showcmd[mode] and true) or false
  end,
})

-- User Commands {{{1

vim.api.nvim_create_user_command('Print', function(ctx) 
  local result = vim.fn.luaeval(ctx.args)
  print(vim.inspect(result))
end, { nargs = '+', complete = "lua" })

-- toggleterm {{{1
if is_windows then
  vim.cmd [[
  let &shell = 'pwsh'
  let &shellcmdflag = '-NoLogo -Command'
  " let &shellcmdflag = '-NoLogo -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
  let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  let &shellpipe  = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
  set shellquote= shellxquote=
  ]]
else
  local zsh_path = vim.fn.exepath('zsh')
  if zsh_path ~= '' then
    vim.opt.shell = zsh_path
  end
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

local function lazygit_setup_cfg()
  local bat_path = is_windows and (vim.fn.tempname() .. ".bat") or nil

  -- lazygit makes it impossible to properly format a <CMD> commands because it naively escapes < to ^<
  -- as a workaround, create a bat file and invoke that instead
  if is_windows then
    local edit_bat = [=[
@echo off

set filename=%1
set linenumber=%2

if "%linenumber%"=="" (
  nvim --server %NVIM% --remote-send "<CMD>lua lazygit_edit_file([[%filename%]])<CR>"
) else (
  nvim --server %NVIM% --remote-send "<CMD>lua lazygit_edit_file([[%filename%]], %linenumber%)<CR>"
)
]=]

    -- windows + lazygit doesn't really mix due to the way lazygit, powershell and cmd.exe works in combination
    -- Create a batch script for editing at specific lines, and a lazygit config for using that batch script

    local batfile = io.open(bat_path, "w")
    batfile:write(edit_bat)
    batfile:close()
  end

  local edit = {
    file = is_windows and (bat_path .. " {{filename}}") or ([=[nvim --server "$NVIM" --remote-send "<CMD>lua lazygit_edit_file([[{{filename}}]])<CR>"]=]),
    line = is_windows and (bat_path .. " {{filename}} {{line}}") or ([=[nvim --server "$NVIM" --remote-send "<CMD>lua lazygit_edit_file([[{{filename}}]], {{line}})<CR>"]=])
  }

  local yml = ([[
os:
  edit: <FILE_EDIT>
  editAtLine: <LINE_EDIT>
  editInTerminal: true
customCommands:
  - key: 'F'
    command: 'git pull --rebase --autostash'
    context: 'localBranches'
    stream: true
gui:
  skipDiscardChangeWarning: true
  theme:
    activeBorderColor:
      - '#a6e3a1'
      - bold
    inactiveBorderColor:
      - '#a6adc8'
    optionsTextColor:
      - '#89b4fa'
    selectedLineBgColor:
      - '#313244'
    cherryPickedCommitBgColor:
      - '#45475a'
    cherryPickedCommitFgColor:
      - '#a6e3a1'
    unstagedChangesColor:
      - '#f38ba8'
    defaultFgColor:
      - '#cdd6f4'
    searchingActiveBorderColor:
      - '#f9e2af'

  authorColors:
    '*': '#b4befe'
notARepository: skip
promptToReturnFromSubprocess: false
keybinding:
  universal:
    quit: <disabled>
    open: <disabled>
]]):gsub("<FILE_EDIT>", edit.file)
  :gsub("<LINE_EDIT>", edit.line)

  local tempcfg = vim.fn.tempname() .. ".yml"
  local file = io.open(tempcfg, "w")
  file:write(yml)
  file:close()
  return tempcfg
end

local lazygit = require("toggleterm.terminal").Terminal:new({
  cmd = 'lazygit --use-config-file "' .. lazygit_setup_cfg() .. '"',
  hidden = true,
  direction = "float",
  on_open = function(term)
    vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-q>", '<cmd>close<cr>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-\\>", '<cmd>close<cr>', { noremap = true, silent = true })
  end,
})
vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "lazygit" })

-- called from the lazygit Edit command via nvim --remote-send
function lazygit_edit_file(file, line)
  if lazygit:is_open() then lazygit:close() end
  -- drop: If the file is open in a window, change to that window. Otherwise
  -- open it in the current buffer. See :help drop
  vim.cmd("drop " .. file)
  local cmd = "normal! "
  if line then
    cmd = cmd .. line .. "gg"
  end
  cmd = cmd .. "zO"
  -- pcall: ignore errors from zO if there are no folds.
  pcall(vim.cmd, cmd)
end


-- dap {{{1

local dap = require('dap')

-- DAP External Terminal {{{2
-- If this is a tmux session, host 'external terminal' in a split
if vim.fn.getenv("TMUX") ~= vim.NIL then
  dap.defaults.fallback.external_terminal = {
    command = vim.fn.exepath('tmux'),
    args = { 
      'split-window', -- create split in the same view
      '-d',  -- don't focus the new split
      '-h',  -- split horizontally
      '-l', '80' -- the new split should take x columns
    }
  }
  -- Otherwise host 'external terminal' in alacritty
elseif vim.fn.executable('alacritty') == 1 then
  dap.defaults.fallback.external_terminal = {
    command = vim.fn.exepath('alacritty'),
    args = { '-e' }
  }
end

-- TODO: {{{2
-- 1. Debug output goes to external console. Is this a:
--   a. netcoredbg issue?
--   b. DAP issue?
--   c. .vscode issue?
--   https://github.com/mfussenegger/nvim-dap/discussions/1006
-- 2. Keybinds
-- 3. dap-ui layouts -- different layouts depending on debugging granularity? (basic layout with only console / locals -> layout with stacks / watches -> layout with everything + repl)
-- 4. Configurations for other languages (C)
-- 5. Configuration provider which is not .vscode - Consider writing a handler for: 
--   a. trivial C projects, 
--   b. trivial C# projects, 
--   c. trivial OpenTAP plugins 
--   :help dap-providers-configs
-- 6. Reliable way of selecting the appropriate debugging window (<leader>bw -> watches -> activating an appropriate layout if watches are not visible)
--endsection
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })

-- C# Debug Adapter {{{2
-- Download netcoredbg from: https://github.com/Samsung/netcoredbg/releases
if is_osx then
  vim.pack.add({
    { src = "https://github.com/Cliffback/netcoredbg-macOS-arm64.nvim" },
  })

  local dap = require('dap')
  require('netcoredbg-macOS-arm64').setup(dap)
  dap.configurations.cs = {}
else
  local netcoredbg = vim.fs.joinpath(tools_dir, 'netcoredbg', 'netcoredbg')
  dap.adapters.coreclr = {
    type = 'executable',
    command = netcoredbg,
    args = { '--interpreter=vscode' }
  }
end

-- C# Unittest debugging {{{2

require('csharp_unittest').setup({})

-- C Debug Adapter {{{2

do
  local c_adapter = {
    type = 'executable',
    -- lldb-dap is distributed with LLVM, so it should be in path if clang is installed.
    command = vim.fn.exepath('lldb-dap'),
    name = "lldb",
  }
  dap.adapters.lldb = c_adapter
  dap.adapters['lldb-dap'] = c_adapter
  dap.adapters.codelldb = c_adapter
  dap.adapters.cppvsdbg = c_adapter
  dap.adapters.cppdbg = c_adapter
end

-- dap ui {{{2
local dap_ui = require('dapui')
dap_ui.setup({
  layouts = { {
      elements = {
        -- { id = "watches", size = 0.10, },
        { id = "breakpoints", size = 0.20, },
        { id = "stacks", size = 0.40, },
        { id = "scopes", size = 0.40, }, 
      },
      position = "left",
      size = 40,
    }, {
      elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 }, },
      position = "bottom",
      size = 10,
    }
  },
})

local dap_layouts = { 1, 2 }
local function dap_toggle_layout(layout)
  for i, l in ipairs(dap_layouts) do
    if l == layout then
      dap_ui.close(layout)
      table.remove(dap_layouts, i)
      return
    end
  end
  dap_layouts[#dap_layouts+1] = layout
  dap_ui.open(layout)
end

local function dap_open() 
  for _, l in ipairs(dap_layouts) 
    do dap_ui.open(l) 
  end
end

dap.listeners.before.attach.dapui_config = dap_open
dap.listeners.before.launch.dapui_config = dap_open
dap.listeners.before.event_terminated.dapui_config = function() dap_ui.close() end
dap.listeners.before.event_exited.dapui_config = function() dap_ui.close() end

-- dap keybinds {{{2

vim.keymap.set('n', 'gt1', function() dap_toggle_layout(1) end)
vim.keymap.set('n', 'gt2', function() dap_toggle_layout(2) end)
vim.keymap.set('n', '<F1>', dap.run_last)
vim.keymap.set('n', '<F2>', dap.terminate)
vim.keymap.set('n', '<F4>', dap.up)
vim.keymap.set('n', '<F5>', dap.continue)
vim.keymap.set('n', '<F7>', dap.down)
vim.keymap.set('n', '<F9>', dap.toggle_breakpoint)
vim.keymap.set('n', '<F10>', dap.step_over)
vim.keymap.set('n', '<F11>', dap.step_into)
vim.keymap.set('n', '<F12>', dap.step_out)

-- dap hover {{{2
do
  local dap_widgets = require('dap.ui.widgets')
  local hover_winid = nil

  local function hover_peek()
    -- if hover_winid is not set, we should open the hover window.
    -- remember the initial window
    local initial_win = vim.fn.winnr()
    -- open the hover window
    dap_widgets.hover()
    -- check the new window
    local win = vim.fn.winnr()
    -- if the window did not change, we shouldn't do anything
    if win == initial_win then 
      return nil
    end
    local winid = vim.fn.win_getid(win)
    -- leave the hover window
    vim.cmd[[wincmd p]]
    return winid
  end

  local function hover_close()
    if hover_winid then
      local winid = hover_winid
      hover_winid = nil
      vim.api.nvim_win_close(winid, false)
    end
  end

  -- if the hover window is open, enter it
  -- otherwise 'peek' it by opening without entering
  local function hover_peek_or_enter()
    if hover_winid then
      -- enter the hover window
      local did_enter = vim.fn.win_gotoid(hover_winid) == 1
      -- map q/esc to close and leave the window
      vim.keymap.set('n', 'q', hover_close, { buffer = vim.fn.bufnr() })
      vim.keymap.set('n', '<esc>', hover_close, { buffer = vim.fn.bufnr() })
    else
      hover_winid = hover_peek()
      if hover_winid then
        -- configure autocommand to close the hover_winid on cursor move
        local augroup = vim.api.nvim_create_augroup('dap-peek-hover-group', { clear = true })
        vim.api.nvim_create_autocmd('CursorMoved', {
          group = augroup,
          callback = function() 
            -- allow cursor movement inside the hover window
            local thiswin = vim.fn.win_getid(vim.fn.winnr())
            if thiswin == hover_winid then return end
            vim.api.nvim_del_augroup_by_id(augroup)
            hover_close()
          end,
        })
      end
    end
  end

  vim.keymap.set('n', 'L', hover_peek_or_enter)
end

-- Modeline {{{1
-- vim: fdm=marker
