require "config.options"
require "config.keymap"
require "config.autocommands"

-- todo: port functions to lua
vim.cmd[[
let s:here=expand("~/.config/nvim/lua/config")
execute 'source ' .. s:here .. '/functions.vim'
]]

