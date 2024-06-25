return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "Issafalcon/neotest-dotnet",
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
