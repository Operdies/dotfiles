require("utils").create_keymap_group("<leader>r", "+run")

return {
	{
		"Operdies/rev.nvim",
		lazy = false,
		dev = true,
		dependencies = { "shiracamus/vim-syntax-x86-objdump-d" },
		keys = {
			{ "<leader>rr", "<cmd>RReload<cr>", desc = "Reload Reverse" },
		},
		opts = {},
		-- empty string should mean binary
		ft = { "hex", "binary" },
	},
	{
		"Operdies/gwatch.nvim",
		lazy = false,
		dev = true,
		keys = {
			{ "<leader>cc", "<cmd>GwatchStart<cr>", desc = "Start Gwatch", mode = "n" },
			{ "<leader>cx", "<cmd>GwatchStop<cr>", desc = "Stop Gwatch", mode = "n" },
			{ "<leader>c,", "<cmd>GwatchSettings<cr>", desc = "Gwatch Settings", mode = "n" },
			{ "<C-q>", "<cmd>GwatchTrigger<cr>", desc = "Gwatch Trigger", mode = "n" },
		},
		opts = {
			-- The width of the UI window
			["window width"] = 80,
			["window height"] = 10,
			["window position"] = "bottom",
			["trigger"] = "hotkey",
		},
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>en",
				function()
					require("trouble").next({ skip_groups = true, jump = true })
				end,
				desc = "Trouble Next",
			},
			{
				"<leader>ep",
				function()
					require("trouble").previous({ skip_groups = true, jump = true })
				end,
				desc = "Trouble Previous",
			},
			{
				"<leader>ef",
				function()
					require("trouble").first({ skip_groups = true, jump = true })
				end,
				desc = "Trouble First",
			},
			{
				"<leader>el",
				function()
					require("trouble").last({ skip_groups = true, jump = true })
				end,
				desc = "Trouble Last",
			},
		},
	},
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
		"christoomey/vim-tmux-navigator",
		init = function()
			vim.g.tmux_navigator_no_mappings = 1
		end,
		keys = {
			{
				"<C-h>",
				function()
					vim.cmd([[TmuxNavigateLeft]])
				end,
				desc = "Tmux Left",
			},
			{
				"<C-l>",
				function()
					vim.cmd([[TmuxNavigateRight]])
				end,
				desc = "Tmux Right",
			},
			{
				"<C-k>",
				function()
					vim.cmd([[TmuxNavigateUp]])
				end,
				desc = "Tmux Up",
			},
			{
				"<C-j>",
				function()
					vim.cmd([[TmuxNavigateDown]])
				end,
				desc = "Tmux Down",
			},
		},
	},
	{
		"codethread/qmk.nvim",
		config = function()
			local conf = {
				name = "LAYOUT_split_3x5_2",
				layout = {
					"x x x x x _ _ _ x x x x x",
					"x x x x x _ _ _ x x x x x",
					"x x x x x _ _ _ x x x x x",
					"_ _ _ _ x x _ x x _ _ _ _",
				},
			}
			require("qmk").setup(conf)
		end,
	},
	{
		"mfussenegger/nvim-dap",
		_config = function()
			-- local dap = require("dap")
			-- local repofs = {
			-- 	name = "repofs",
			-- 	type = "codelldb", -- matches the adapter
			-- 	request = "launch", -- could also attach to a currently running process
			-- 	program = "${workspaceFolder}/bin/repofs",
			-- 	cwd = "${workspaceFolder}",
			-- 	stopOnEntry = false,
			-- 	args = { "-f", "-s", "-o", "auto_unmount", "/home/alex/mounts/repo" },
			-- 	runInTerminal = false,
			-- }
			-- table.insert(dap.configurations.c, 1, repofs)
		end,
	},
}
