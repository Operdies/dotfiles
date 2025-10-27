return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      no_italic = true,
      background = {
        light = "latte",
        dark = "mocha",
      },
      highlight_overrides = {
        mocha = function(_)
          return {
            WinSeparator = { fg = "#4E4E6E", },
          }
        end,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

}
