-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Override LazyVim defaults
pcall(vim.keymap.del, "n", "<leader>gG")

local map = vim.keymap.set
local opts = { silent = true }


-- Insert blank line before/after cursor and restore position
map("n", "[<space>", "mlO<Esc>`l", opts)
map("n", "]<space>", "mlo<Esc>`l", opts)

