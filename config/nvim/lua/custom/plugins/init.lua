return {
	{
		"stevearc/oil.nvim",
		cmd = { "Oil " },
		config = true,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>o",
				'<cmd>lua require("oil").open()<CR>',
				desc = "Open parent directory",
			},
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
			{ "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
		},
		opts = {
			modes = {
				char = {
					jump_labels = true
				}
			}
		},
	},
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{
				"H",
				mode = { "n" },
				":bprev<CR>",
				desc =
				"Previous Buffer",
			},
			{ "L",          mode = { "n" },                            ":bnext<CR>",                      desc = "Next Buffer", },
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Toggle pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
		},
		opts = {
			options = {
				close_command = function(n) require("mini.bufremove").delete(n, false) end,
				right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
				diagnostics = "nvim_lsp",
				always_show_bufferline = true,
			},
		},
	},
}
