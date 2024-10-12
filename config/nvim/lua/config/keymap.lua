local opts = { silent = true, noremap = true }
local function nmap(keys, action)
  vim.keymap.set("n", keys, action, opts)
end

local function vmap(keys, action)
  vim.keymap.set("v", keys, action, opts)
end

local function imap(keys, action)
  vim.keymap.set("i", keys, action, opts)
end

-- Insert blank line before/after cursor and restore position
nmap("[<space>", "m'O<esc>`'")
nmap("]<space>", "m'o<esc>`'")
-- restore position after reindenting
nmap("=ip", "m`=ip``")
-- visual select last paste
nmap("gp", "`[v`]")
nmap("<C-s>", ":w<cr>")
nmap("<esc>", "<esc>:nohlsearch<cr>")
nmap("<S-h>", ":bprev<cr>")
nmap("<S-l>", ":bnext<cr>")
-- delete the active buffer without deleting its window
nmap("<leader>bd", ":bp|bd #<cr>")
nmap("g?", function()
  local success, err = pcall(function() vim.cmd("Man " .. vim.fn.expand("<cword>")) end)
  if not success then
    -- vim.api.nvim_err_writeln
    print(err)
  end
end)

vmap("<M-j>", ":m '>+1<cr>gv=gv")
vmap("<M-k>", ":m '<-2<cr>gv=gv")
nmap("<M-j>", ":m .+1<cr>==")
nmap("<M-k>", ":m .-2<cr>==")

nmap("<C-]>", "g<C-]>")
nmap("<C-j>", ":execute 'ptag ' .. expand('<cword>')<cr>")

-- create undo point before pasting
imap("<C-r>", "<C-G>u<C-r>")

-- keep visual selection when 'denting
vmap("<", "<gv")
vmap(">", ">gv")

imap("<C-d>", "<del>")

-- double escape: go to normal mode from a terminal
vim.keymap.set("t", "<C-o><C-o>", "<C-\\><C-n>")

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Show me the man pages
vim.keymap.set('n', '<C-k>', "<cmd>Man<cr>", { desc = "Open manual for word under cursor.", silent = true, noremap = true, remap = true})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '[q', ':cprev<cr>', { desc = 'Go to previous quickfix item' })
vim.keymap.set('n', ']q', ':cnext<cr>', { desc = 'Go to next quickfix item' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
-- Register access with " feels super awkward. Set up + and - as easy access registers
vim.keymap.set({ 'v', 'n' }, '-', '"-', { desc = "Copy to - register", noremap = true })
vim.keymap.set({ 'v', 'n' }, '+', '"+', { desc = "Copy to system clipboard", noremap = true })

local function add_header_guard()
  local guard = vim.fn.expand('%:t:r'):upper() .. "_H"
  vim.fn.append(0, "#ifndef " .. guard)
  vim.fn.append(1, "#define " .. guard)
  vim.fn.append(2, "")
  vim.fn.append(vim.fn.line('$'), "")
  vim.fn.append(vim.fn.line('$'), "#endif //  " .. guard)
end

local function scrolloff_reader()
  local deactivate = vim.wo.scrolloff
  local activate = 99
  return function()
    if vim.wo.scrolloff == activate then
      vim.wo.scrolloff = deactivate
    else
      deactivate = vim.wo.scrolloff
      vim.wo.scrolloff = activate
    end
  end
end

vim.keymap.set('n', '<leader>tr', scrolloff_reader(), { desc = "Toggle Reader Mode" })
vim.api.nvim_create_user_command('AddHeaderGuard', add_header_guard, {})
