return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    keys = {
      { "<M-j>", mode = "i" },
    },
    opts = {
      suggestion = {
        keymap = {
          next = "<M-j>",
          prev = "<M-k>",
          accept = "<M-e>",
        }
      },
      panel = { enabled = false },
    },
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" },  -- for curl, log wrapper
    },
    build = "make tiktoken",        -- Only on MacOS or Linux
    cmd = "CopilotChat",
    opts = function()
      local user = vim.env.USER or "User"
      user = user:sub(1, 1):upper() .. user:sub(2)
      return {
        model = "gpt-4o",
        temperature = 0.1,
        auto_insert_mode = true,
        show_help = false,
        question_header = "Alex",
        answer_header = "Casey",
        window = {
          width = 0.4,
        },
        system_prompt =
        [[You will answer all queries briefly at a high level and avoid diving into necessary detail unless asked to elaborate. When discussing code, always assume the language is C, unless otherwise specified. You will avoid using deprecated standard library functions. You will only provide code examples upon request. Keep examples short and to the point. When doing code examples, you will not use any libraries, and instead assume we can only use code in the current codebase.]],
        prompt = '',
        selection = function(source)
          local select = require("CopilotChat.select")
          return select.visual(source) or select.buffer(source)
        end,
      }
    end,
    keys = {
      {
        "<leader>qa",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>qx",
        function()
          return require("CopilotChat").reset()
        end,
        desc = "Clear (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>qq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input)
          end
        end,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })

      chat.setup(opts)
    end,
  },
}
