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
-- reindent on paste
nmap("p", "p`[v`]=")
nmap("<S-p>", "P`[v`]=")
-- visual select last paste
nmap("gp", "`[v`]")
nmap("<C-s>", ":w<cr>")
nmap("<esc>", "<esc>:nohlsearch<cr>")
nmap("<S-h>", ":bprev<cr>")
nmap("<S-l>", ":bnext<cr>")
nmap("<leader>bd", ":bdelete<cr>")
nmap("g?", function()
  local success, err = pcall(function() vim.cmd("Man " .. vim.fn.expand("<cword>")) end)
  if not success then
    -- vim.api.nvim_err_writeln
    print(err)
  end
end)

vim.keymap.set({ "v", "n" }, "<leader>cf", vim.lsp.buf.format, opts)
vmap("<M-j>", ":m '>+1<cr>gv=gv")
vmap("<M-k>", ":m '<-2<cr>gv=gv")
nmap("<M-j>", ":m .+1<cr>==")
nmap("<M-k>", ":m .-2<cr>==")

-- create undo point before pasting
imap("<C-r>", "<C-G>u<C-r>")

-- keep visual selection when 'denting
vmap("<", "<gv")
vmap(">", ">gv")

imap("", "<del>")
