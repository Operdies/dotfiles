return {
	{
		"nvim-neotest/neotest",
		opts = {
			adapters = {
				["neotest-dotnet"] = {},
			},
		},
		dependencies = {
			"Issafalcon/neotest-dotnet",
			config = function(_, opts)
				-- local install_dir = path.concat({ vim.fn.stdpath("data"), "mason" })
				local install_dir = vim.fn.stdpath("data") .. "/" .. "mason"

				local dap = require("dap")
				dap.adapters.coreclr = {
					type = "executable",
					command = install_dir .. "/packages/netcoredbg/netcoredbg",
					args = { "--interpreter=vscode" },
				}

				dap.adapters.netcoredbg = {
					type = "executable",
					command = install_dir .. "/packages/netcoredbg/netcoredbg",
					args = { "--interpreter=vscode" },
				}
				dap.configurations.cs = {
					{
						type = "coreclr",
						name = "launch - netcoredbg",
						request = "launch",
						program = function()
							return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
						end,
					},
				}
			end,
		},
	},
}
