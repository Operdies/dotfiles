return {
  {
    "catppuccin/nvim",
    priority = 1000,
    name = "catppuccin",
    config = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
    opts = {
      term_colors = true,
      color_overrides = {
        mocha = {
          base = "#0D1117",
        },
      },
    },
  },
}
