-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Override LazyVim defaults
local map = vim.keymap.set
local opts = { silent = true, noremap = true }
local function nmap(keys, action)
	map("n", keys, action, opts)
end

-- Insert blank line before/after cursor and restore position
nmap("[<space>", "m'O<esc>`'")
nmap("]<space>", "m'o<esc>`'")

vim.cmd[[
let s:here=expand("~/.config/nvim/lua/config")
execute 'source ' .. s:here .. '/options.vim'
execute 'source ' .. s:here .. '/keymap.vim'
execute 'source ' .. s:here .. '/functions.vim'
execute 'source ' .. s:here .. '/autocommands.vim'
]]
