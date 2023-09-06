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


map("i", "<M-h>", '<C-o>b', opts)
map("i", "<M-l>", '<C-o>e<C-o>l', opts)

map("i", "<C-h>", '<C-o>h', opts)
map('i', '<C-l>', '<C-o>l', opts)

map("i", "<M-C-h>", '<C-o>B', opts)
map("i", "<M-C-l>", '<C-o>E<C-o>l', opts)

map('i', '<M-C-j>', '<C-o>gj', opts)
map('i', '<M-C-k>', '<C-o>gk', opts)

