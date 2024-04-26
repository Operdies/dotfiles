return {
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    event = "VeryLazy",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      panel = { enabled = false },
      suggestion = {
        keymap = {
          next = "<M-j>",
          prev = "<M-k>",
          accept = "<M-e>",
        }
      },
    },
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
    branch = "canary",
    event = "VeryLazy",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" },  -- for curl, log wrapper
      { "ibhagwan/fzf-lua" },       -- for picker
    },
    opts = {
      name = 'Copilot',
      window = {
        layout = 'horizontal',
      },
      prompts = {
        FixDiagnostic = {
          mapping = '<leader>ar',
          description = 'AI Fix Diagnostic',
        },
        Explain = {
          prompt = '/COPILOT_EXPLAIN /USER_EXPLAIN',
          mapping = '<leader>ae',
          description = 'AI Explain',
        },
        Documentation = {
          prompt = '/COPILOT_DEVELOPER /USER_DOCS',
          mapping = '<leader>ad',
          description = 'AI Documentation',
        },
        Fix = {
          prompt = '/COPILOT_DEVELOPER /USER_FIX',
          mapping = '<leader>af',
          description = 'AI Fix',
        },
        Optimize = {
          prompt = '/COPILOT_DEVELOPER Optimize the selected code to improve performance and readability.',
          mapping = '<leader>ao',
          description = 'AI Optimize',
        },
        Simplify = {
          prompt = '/COPILOT_DEVELOPER Simplify the selected code and improve readability',
          mapping = '<leader>as',
          description = 'AI Simplify',
        },
      },
    },
    keys = {
      { "<leader>aa", function() require('CopilotChat').toggle() end, "Toggle Chat" },
      { "<leader>ax", function() require('CopilotChat').reset() end,  "Reset Chat" },
    },
    config = function(_, opts)
      local chat = require('CopilotChat')
      local actions = require('CopilotChat.actions')
      local integration = require('CopilotChat.integrations.fzflua')

      local function pick(pick_actions)
        return function()
          integration.pick(pick_actions(), {}, {
            fzf_tmux_opts = {
              ['-d'] = '45%',
            },
          })
        end
      end

      chat.setup(opts)
      vim.keymap.set(
        { 'n', 'v' },
        '<leader>ap',
        pick(actions.prompt_actions),
        { desc = 'AI Prompt Actions' }
      )
    end
  },
}
