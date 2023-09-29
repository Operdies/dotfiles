return {
  {
    'echasnovski/mini.ai',
    version = '*',
    config = function()
      require("mini.ai").setup()
    end
  },
  {
    'echasnovski/mini.surround',
    version = '*',
    config = function()
      require("mini.surround").setup()
    end
  },
  {
    'echasnovski/mini.bufremove',
    version = '*',
    config = function()
      require("mini.bufremove").setup()
    end
  },
}
