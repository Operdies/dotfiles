return {
	{
		"stevearc/oil.nvim",
		cmd = { "Oil " },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>o",
				'<cmd>lua require("oil").open()<CR>',
				desc = "Open parent directory",
			},
		},
		opts = {
			view_options = {
				show_hidden = true,
			},
		},
	},
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		keys = {
			{ "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Project Files" },
			{ "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Live Grep" },
			{ "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
      { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Recent Files" },
		},
		dependencies = {
			'nvim-lua/plenary.nvim',
			-- Fuzzy Finder Algorithm which requires local dependencies to be built.
			-- Only load if `make` is available. Make sure you have the system
			-- requirements installed.
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				-- NOTE: If you are having trouble with this installation,
				--       refer to the README for telescope-fzf-native for more instructions.
				build = 'make',
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			},
		},
	},
}
