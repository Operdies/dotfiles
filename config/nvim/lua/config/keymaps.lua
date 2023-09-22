-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Override LazyVim defaults
pcall(vim.keymap.del, "n", "<leader>gG")

local map = vim.keymap.set
local opts = { silent = true, remap = true, noremap = false }


-- Insert blank line before/after cursor and restore position
map("n", "[<space>", "mlO<Esc>`l", opts)
map("n", "]<space>", "mlo<Esc>`l", opts)


map("i", "<C-b>", '<C-o>h', opts)
map('i', '<C-f>', '<C-o>a', opts)
map("i", "<M-b>", '<C-o>b', opts)
map("i", "<M-f>", '<C-o>e<C-o>a', opts)
map("i", "<M-C-b>", '<C-o>B', opts)
map("i", "<M-C-f>", '<C-o>E<C-o>a', opts)

map('i', '<M-C-j>', '<C-o>gj', opts)
map('i', '<M-C-k>', '<C-o>gk', opts)

