return {
  {
    "mfussenegger/nvim-dap",

    dependencies = {

      -- fancy UI for the debugger
      {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          "nvim-neotest/nvim-nio",
          "jay-babu/mason-nvim-dap.nvim",
        },
        -- stylua: ignore
        keys = {
          { "<leader>du",    function() require("dapui").toggle({}) end,                  desc = "Dap UI" },
          { "<leader>k",     function() require("dapui").eval(nil, { enter = true }) end, desc = "Eval",  mode = { "n", "v" } },
          { "<2-LeftMouse>", function() require("dapui").eval(nil, { enter = false }) end, desc = "Eval",  mode = { "n", "v" } },
        },
        opts = {},
        config = function(_, opts)
          -- setup dap config by VsCode launch.json file
          -- require("dap.ext.vscode").load_launchjs()
          local dap = require("dap")
          local ui = require("dapui")
          ui.setup(opts)
          dap.listeners.before.attach.dapui_config = function()
            ui.open()
          end
          dap.listeners.before.launch.dapui_config = function()
            ui.open()
          end
          dap.listeners.before.event_terminated.dapui_config = function()
            ui.close()
          end
          dap.listeners.before.event_exited.dapui_config = function()
            ui.close()
          end

          local function scan_executables()
            local function scan_dir(cfgs, dir)
              local ok, executables = pcall(vim.fn.systemlist, { 'fd', '.', dir, '-u', '-t', 'x' })
              if ok and executables then
                local seen = {}
                for ex in pairs(executables) do
                  local nm = executables[ex]
                  local index = string.find(nm, "/[^/]*$")
                  local pretty = nm:sub(1 + (index or 0))
                  local existing = seen[pretty]
                  if existing ~= nil then
                    pretty = nm
                    cfgs[existing.index].name = executables[existing.sourceIndex]
                  end
                  seen[pretty] = { index = #cfgs + 1, sourceIndex = ex }

                  cfgs[#cfgs + 1] = {
                    args = {},
                    console = "integratedTerminal",
                    cwd = "${workspaceFolder}",
                    name = pretty,
                    program = nm,
                    request = "launch",
                    stopOnEntry = false,
                    type = "codelldb"
                  }
                end
              end
            end
            local cfgs = {}
            scan_dir(cfgs, 'out')
            scan_dir(cfgs, 'build')
            dap.configurations.c = cfgs
          end
          vim.keymap.set("n", "<leader>dr", scan_executables, { desc = "Scan for executables (lldb)" })


          if not dap.adapters["netcoredbg"] then
            require("dap").adapters["netcoredbg"] = {
              type = "executable",
              command = vim.fn.exepath("netcoredbg"),
              args = { "--interpreter=vscode" },
            }
          end
          for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
            if not dap.configurations[lang] then
              dap.configurations[lang] = {
                {
                  type = "netcoredbg",
                  name = "Launch file",
                  request = "launch",
                  ---@diagnostic disable-next-line: redundant-parameter
                  program = function()
                    return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
                  end,
                  cwd = "${workspaceFolder}",
                },
              }
            end
          end
        end,
      },

      -- virtual text for the debugger
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },

      -- mason.nvim integration
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          -- Makes a best effort to setup the various debuggers with
          -- reasonable debug configurations
          automatic_installation = true,

          -- You can provide additional configuration to the handlers,
          -- see mason-nvim-dap README for more information
          handlers = {},

          -- You'll need to check that you have the required things installed
          -- online, please don't ask me how to install them :)
          ensure_installed = {
            -- Update this to ensure that you have the debuggers for the langs you want
          },
        },
      },
    },

    -- stylua: ignore
    keys = {
      { "<F9>",       function() require("dap").toggle_breakpoint() end,             desc = "Toggle Breakpoint" },
      { "<F5>",       function() require("dap").continue() end,                      desc = "Continue" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<leader>dg", function() require("dap").goto_() end,                         desc = "Go to line (no execute)" },
      { "<F4>",       function() require("dap").up() end,                            desc = "Up" },
      { "<F7>",       function() require("dap").down() end,                          desc = "Down" },
      { "<F1>",       function() require("dap").run_last() end,                      desc = "Run Last" },
      { "<F10>",      function() require("dap").step_over() end,                     desc = "Step Over" },
      { "<F11>",      function() require("dap").step_into() end,                     desc = "Step Into" },
      { "<F12>",      function() require("dap").step_out() end,                      desc = "Step Out" },
      { "<leader>dp", function() require("dap").pause() end,                         desc = "Pause" },
      { "<leader>ds", function() require("dap").session() end,                       desc = "Session" },
      { "<F2>",       function() require("dap").terminate() end,                     desc = "Terminate" },
      { "<F17>",      function() require("dap").terminate() end,                     desc = "Terminate" },
      { "<F8>",       function() require("dap.ui.widgets").hover() end,              desc = "Widgets" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end,              desc = "Widgets" },
    },

    config = function()
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },
  {
    "stevearc/overseer.nvim",
    keys = {
      {
        "<leader>rp",
        "<cmd>OverseerLoadBundle<cr>",
        desc = "Pick a saved task bundle",
      },
      {
        "<leader>rw",
        "<cmd>OverseerQuickAction watch<cr>",
        desc = "Rerun on save (Overseer)",
      },
      {
        "<leader>rt",
        "<cmd>OverseerRun<cr>",
        desc = "Run task (Overseer)",
      },
      {
        "<leader>rT",
        "<cmd>OverseerToggle<cr>",
        desc = "Toggle task list (Overseer)",
      },
      {
        "<leader>rr",
        "<cmd>OverseerQuickAction restart<cr>",
        desc = "Restart the most recent overseer action",
      },
    },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 15,
        default_detail = 2,
        dap = true,
        bindings = {
          ["<C-c>"] = "<cmd>OverseerQuickAction stop<cr>",
          ["<C-r>"] = "<cmd>OverseerQuickAction restart<cr>",
        }
      },
    },
  },
}
