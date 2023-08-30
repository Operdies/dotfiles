return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- Disable snippets in completion
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Disable auto selection of first item in completion (1)
      opts.completion.completeopt = "menu,menuone,noinsert,noselect"

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-a>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<C-e>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }),
      })

      -- Disable auto selection of first item in completion (2)
      opts.preselect = require("cmp").PreselectMode.None

      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
        { name = "nvim_lsp_signature_help" },
      }))
    end,
  },
}
