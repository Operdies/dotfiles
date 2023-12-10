return {
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		config = function(_, opts)
			local toggleterm = require("toggleterm")
			toggleterm.setup(opts)
		end,
		keys = {
			{ "<c-t>" },
			{
				"<leader>gd",
				(function()
					local session = nil
					return function()
						if session == nil then
							session = require("toggleterm.terminal").Terminal:new({
								cmd = "gdb",
								hidden = true,
								direction = "float",
							})
						end
						session:toggle()
					end
				end)(),
				desc = "gdb",
			},
			{
				"<leader>gg",
				function()
					require("toggleterm.terminal").Terminal
						:new({ cmd = "lazygit", hidden = true, direction = "float" })
						:toggle()
				end,
				desc = "lazygit",
			},
		},
		opts = {
			direction = "float",
			size = 20,
			open_mapping = [[<c-t>]],
			hide_numbers = true,
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			insert_mappings = false,
			persist_size = true,
			persist_mode = false,
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "curved",
			},
			autochdir = true,
			env = {
				EDITOR = "nvr -l",
			},
		},
	},
}
