return {
  -- Adds many new a/i targets - e.g. ciq to chaing text within any quote
  {
    'echasnovski/mini.ai',
    version = '*',
    config = function()
      require("mini.ai").setup()
    end
  },
  -- Bindings for surrounding text with any char
  {
    'echasnovski/mini.surround',
    version = '*',
    config = function()
      require("mini.surround").setup()
    end
  },
  -- Delete / insert matching pairs
  {
    'echasnovski/mini.pairs',
    version = '*',
    config = function()
      require("mini.pairs").setup()
    end
  },
  -- Provides convenient functions for removing a buffer without changing the window layout
  {
    "echasnovski/mini.bufremove",
    -- stylua: ignore
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end,  desc = "Delete Buffer (Force)" },
    },
  },
  -- Convenient text operator -- gx to exchange text, gr to exchange with register
  {
    'echasnovski/mini.operators',
    version = '*',
    config = function()
      require("mini.operators").setup()
    end
  },
  -- Animate motions so jumps are less disorienting
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs({ "Up", "Down" }) do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require("mini.animate")
      return {
        resize = { enable = false },
        open = { enable = false },
        cursor = { enable = false },
        close = { enable = false },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 60, unit = "total" }),
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          }),
        },
      }
    end,
  },
  {
    'echasnovski/mini.move',
    version = '*',
    config = function()
      require("mini.move").setup()
    end
  }
}
