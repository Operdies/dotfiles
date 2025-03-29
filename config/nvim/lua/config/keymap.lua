local defaultMapOpts = { silent = true, noremap = true }
local function nmap(keys, action)
  vim.keymap.set("n", keys, action, defaultMapOpts)
end

local function vmap(keys, action)
  vim.keymap.set("v", keys, action, defaultMapOpts)
end

local function imap(keys, action)
  vim.keymap.set("i", keys, action, defaultMapOpts)
end

local function map(modes, keys, action, opts)
  vim.keymap.set(modes, keys, action, opts or defaultMapOpts)
end

nmap("]<tab>", "<cmd>tabnext<cr>")
nmap("[<tab>", "<cmd>tabprev<cr>")
-- restore position after reindenting
nmap("=ip", "m`=ip``")
-- visual select last paste
nmap("gp", "`[v`]")
nmap("<C-s>", "<cmd>w<cr>")
nmap("<esc>", "<esc><cmd>nohlsearch<cr>")
nmap("<S-h>", "<cmd>bprev<cr>")
nmap("<S-l>", "<cmd>bnext<cr>")
-- delete the active buffer without deleting its window
nmap("<leader>bd", "<cmd>bp|bd #<cr>")
nmap("g?", function()
  local success, err = pcall(function() vim.cmd("Man " .. vim.fn.expand("<cword>")) end)
  if not success then
    -- vim.api.nvim_err_writeln
    print(err)
  end
end)

vmap("<M-j>", "<cmd>m '>+1<cr>gv=gv")
vmap("<M-k>", "<cmd>m '<-2<cr>gv=gv")
nmap("<M-j>", "<cmd>m .+1<cr>==")
nmap("<M-k>", "<cmd>m .-2<cr>==")

nmap("<C-]>", "g<C-]>")
nmap("<C-j>", "<cmd>execute 'ptag ' .. expand('<cword>')<cr>")

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
map('n', '[d', function() vim.diagnostic.jump({count=-1, float=true}) end, { desc = 'Go to previous diagnostic message' })
map('n', ']d', function() vim.diagnostic.jump({count=1, float=true}) end, { desc = 'Go to next diagnostic message' })
map('n', '[q', '<cmd>cprev<cr>', { desc = 'Go to previous quickfix item' })
map('n', ']q', '<cmd>cnext<cr>', { desc = 'Go to next quickfix item' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
-- Register access with " feels super awkward. Set up + and - as easy access registers
map({ 'v', 'n' }, '-', '"-', { desc = "Copy to - register", noremap = true })
map({ 'v', 'n' }, '+', '"+', { desc = "Copy to system clipboard", noremap = true })

local function add_header_guard()
  local guard = vim.fn.expand('%:t:r'):upper() .. "_H"
  vim.fn.append(0, "#ifndef " .. guard)
  vim.fn.append(1, "#define " .. guard)
  vim.fn.append(2, "")
  vim.fn.append(vim.fn.line('$'), "")
  vim.fn.append(vim.fn.line('$'), "#endif /*  " .. guard .. " */")
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
