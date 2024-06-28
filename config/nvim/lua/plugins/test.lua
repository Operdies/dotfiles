return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "Issafalcon/neotest-dotnet",
    },
    keys = {
      { "<leader>uR", function() require('neotest').run.run_last() end, desc = "Run recent test" },
      { "<leader>ud", function() require("neotest").run.run({ strategy = "dap" }) end,  desc = "Debug closest test" },
      { "<leader>uD", function() require("neotest").run.run_last({ strategy = "dap" }) end,  desc = "Debug recent test" },
      { "<leader>us", "<cmd>Neotest summary<cr>", desc = "Open test browser" },
      { "<leader>ur", "<cmd>Neotest run<cr>", desc = "Run closest test" },
      { "<leader>ua", "<cmd>Neotest stop<cr>",  desc = "Stop running test" },
      { "[t", "<cmd>Neotest jump prev<cr>",  desc = "Go to previous test" },
      { "]t", "<cmd>Neotest jump next<cr>",  desc = "Go to next test" },
    },
    opts = function()
      return {
        adapters = {
          require('neotest-dotnet')
        }
      }
    end,
  },
}
