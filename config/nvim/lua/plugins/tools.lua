return {
	{
		"Operdies/gwatch.nvim",
		dev = true,
		event = "VeryLazy",
		keys = {
			{ "<leader>cc", '<cmd>GwatchStart<cr>',    desc = "Start Gwatch",    mode = "n" },
			{ "<leader>cx", '<cmd>GwatchStop<cr>',     desc = "Stop Gwatch",     mode = "n" },
			{ "<leader>c,", '<cmd>GwatchSettings<cr>', desc = "Gwatch Settings", mode = "n" },
			{ "<C-q>",      '<cmd>GwatchTrigger<cr>',  desc = "Gwatch Trigger",  mode = "n" },
		},
		opts = {
			mode = "kill",
			trigger = "hotkey",
			["window position"] = "bottom",
			["window height"] = "15",
		},
		config = function(_, opts)
			local g = require('gwatch')
			g.setup(opts)
		end
	}
}
