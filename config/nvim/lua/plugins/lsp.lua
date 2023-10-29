return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "Hoffs/omnisharp-extended-lsp.nvim",
    },
    opts = function(_, opts)
      ---@type lspconfig.options
      opts.servers = {
        helm_ls = {
          cmd = { "helm_ls", "serve" },
          filetypes = { "helm" },
          mason = false,
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              ---@diagnostic disable-next-line: assign-type-mismatch
              checkOnSave = {
                command = "clippy",
              },
              diagnostics = {
                enable = true,
                -- There is a bug in rust-analyzer causing this to trigger constantly.
                -- TODO: Check if this is fixed at some point
                disabled = { "unresolved-proc-macro" },
                enableExperimental = true,
              },
            },
          },
        },
        omnisharp = {
          filetypes = { "cs", "csx" },
          handlers = {
            ["textDocument/definition"] = require("omnisharp_extended").handler,
          },
          on_attach = function(client, bufnr)
            vim.keymap.set( "n", "gd", "<cmd>lua require('omnisharp_extended').telescope_lsp_definitions()<cr>", { buffer = bufnr, desc = "Goto Definition" })
          end,
        },
      }
      opts.setup = {
        clangd = function(_, opts)
          opts.capabilities.offsetEncoding = { "utf-16" }
        end,
        helm_ls = function(_, _)
          local configs = require("lspconfig.configs")
          if not configs.helm_ls then
            configs.helm_ls = {
              default_config = {
                cmd = { "helm_ls", "serve" },
                filetypes = { "helm" },
                root_dir = function(fname)
                  local util = require("lspconfig.util")
                  return util.root_pattern("Chart.yaml")(fname)
                end,
              },
            }
          end
          return false
        end,
        tailwindcss = function()
          require("lazyvim.util").on_attach(function(client, _)
            if client.name == "tailwindcss" then
              client.server_capabilities.documentFormattingProvider = true
            end
          end)
        end,
        eslint = function()
          require("lazyvim.util").on_attach(function(client, _)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            end
          end)
        end,
      }
    end,
  },
}
