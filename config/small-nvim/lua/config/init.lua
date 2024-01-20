-- require "config.options"
-- require "config.keymap"
-- require "config.autocommands"

vim.cmd[[
let s:here=expand("~/.config/nvim/lua/config")
execute 'source ' .. s:here .. '/functions.vim'
]]

