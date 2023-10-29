return {
	{
		"goolord/alpha-nvim",
		enabled = false,
	},
	{
		"folke/persistence.nvim",
		enabled = false,
	},
	{
		"neo-tree.nvim",
		enabled = false,
	},
	{
		"echasnovski/mini.pairs",
		enabled = false,
	},
	{
		"echasnovski/mini.surround",
		enabled = false,
	},
	{
		"akinsho/bufferline.nvim",
		keys = {
			{
				"<leader>bO",
				function()
					local buf = require("bufferline")
					buf.close_others()
				end,
				desc = "Close other buffers",
				mode = "n",
			},
		},
		opts = {
			options = {
				always_show_bufferline = true,
			},
		},
	},
}
