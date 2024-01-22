return {
	{
		"stevearc/overseer.nvim",
		keys = {
			{
				"<leader>rt",
				"<cmd>OverseerRun<cr>",
				desc = "Run task (Overseer)",
			},
			{
				"<leader>rT",
				"<cmd>OverseerToggle<cr>",
				desc = "Toggle task list (Overseer)",
			},
		},
		opts = {
			task_list = {
				direction = "bottom",
			},
		},
	},
}
