---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
    if config.type and config.type == "java" then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

return {
  {
    "mfussenegger/nvim-dap",

    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-dap.nvim",

      -- fancy UI for the debugger
      {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          "nvim-neotest/nvim-nio",
          "jay-babu/mason-nvim-dap.nvim",
          "stevearc/overseer.nvim", -- needed for .vscode task integration
        },
        -- stylua: ignore
        keys = {
          { "<leader>du",    function() require("dapui").toggle({}) end,                   desc = "Dap UI" },
          { "<leader>k",     function() require("dapui").eval(nil, { enter = true }) end,  desc = "Eval",  mode = { "n", "v" } },
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
            local found = false
            local function scan_dir(cfgs, dir)
              -- check if dir exists
              if vim.fn.isdirectory(dir) == 0 then
                return
              end

              local ok, executables = pcall(vim.fn.systemlist, { 'fd', '.', dir, '-t', 'x' })
              if ok and executables then
                found = true
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

          -- if not dap.adapters["netcoredbg"] then
          --   require("dap").adapters["netcoredbg"] = {
          --     type = "executable",
          --     command = vim.fn.exepath("netcoredbg"),
          --     args = { "--interpreter=vscode" },
          --     options = {
          --       detached = false,
          --     },
          --   }
          -- end
          -- dap.adapters.coreclr = dap.adapters.netcoredbg
          --
          -- for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
          --   if not dap.configurations[lang] then
          --     dap.configurations[lang] = {
          --       {
          --         type = "netcoredbg",
          --         name = "Launch file",
          --         request = "launch",
          --         ---@diagnostic disable-next-line: redundant-parameter
          --         program = function()
          --           return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
          --         end,
          --         cwd = "${workspaceFolder}",
          --       },
          --     }
          --   end
          -- end
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
      -- Custom handling of handshake from vsdbg
      -- from https://github.com/mfussenegger/nvim-dap/discussions/869#discussioncomment-8121995
      local utils = require("dap.utils")

      local rpc = require("dap.rpc")

      local function send_payload(client, payload)
        local msg = rpc.msg_with_content_length(vim.json.encode(payload))
        client.write(msg)
      end

      function RunHandshake(self, request_payload)
        local signResult = io.popen("node ~/.config/nvim/vsdbgsign/vsdbgsign.js " .. request_payload.arguments.value)
        -- utils.notify('signing handshake', vim.log.levels.INFO)
        if signResult == nil then
          utils.notify("error while signing handshake", vim.log.levels.ERROR)
          return
        end
        local signature = signResult:read("*a")
        signature = string.gsub(signature, "\n", "")
        local response = {
          type = "response",
          seq = 0,
          command = "handshake",
          request_seq = request_payload.seq,
          success = true,
          body = {
            signature = signature,
          },
        }
        send_payload(self.client, response)
      end

      -- end of handshake handling

      local dap = require("dap")
      -- dap.defaults.fallback.terminal_win_cmd = "50split new"
      -- dap.defaults.fallback.external_terminal = {
      --   command = "alacritty",
      --   args = { "-e" },
      -- }
      -- dap.defaults.fallback.external_terminal = {
      --   command = "tmux",
      --   args = { "split-window", "-h", "-l", "40%" },
      -- }
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })

      -- Old Config if vsdbg from VSCode is not working:
      -- dap.adapters.coreclr = {
      --   type = "executable",
      --   command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
      --   args = {"--interpreter=vscode"}
      -- }

      -- Figure out the path to the vsdbg-ui executable
      local ui = vim.fn.glob("~/.vscode/extensions/**/.debugger/**/vsdbg-ui")
      local vsdbgPath = vim.split(ui, "\n")
          [1] -- on macOS, there are two paths, the first one is for arm64 the second one is for x86_64
      -- print("vsdbgPath", vsdbgPath)

      local function trim_procname(name, columns, wordlimit)
        local function trimpart(part, i)
          if #part <= wordlimit then
            return part
          end
          -- `/usr/bin/cmd` -> `cmd`
          part = part:gsub("(/?[^/]+/)", "")

          -- preserve command name in full length, but trim arguments if they exceed word limit
          if i > 1 and #part > wordlimit then
            return "‥" .. part:sub(#part - wordlimit)
          end
          return part
        end

        -- proc name can include arguments `foo --bar --baz`
        -- trim each element and drop trailing args if still too long
        local i = 0
        local parts = {}
        local len = 0
        for word in name:gmatch("[^%s]+") do
          i = i + 1
          -- the first word is the dotnet executable, skip it
          if i > 1 then
            local trimmed = trimpart(word, i)
            len = len + #trimmed
            if i > 1 and len > columns then
              table.insert(parts, "[‥]")
              break
            else
              table.insert(parts, trimmed)
            end
          end
        end
        return i > 0 and table.concat(parts, " ") or trimpart(name, 1)
      end
      local attach_proc_label_fn = function(proc)
        local name = trim_procname(proc.name, 200, 50)
        return string.format("id=%d cmd=%s", proc.pid, name)
      end

      local attach_proc_filter_fn = function(proc)
        -- split the name into executable and arguments
        local words = {}
        for word in proc.name:gmatch("[^%s]+") do
          table.insert(words, word)
        end
        if (words == nil or #words < 2) then
          return false
        end

        if (not words[1]:match("/dotnet$")) then
          return false
        end
        if (not words[2]:match("dll$")) then
          return false
        end
        if (words[2]:match("LanguageServer")) then
          return false
        end
        return true
      end

      dap.adapters.coreclr = {
        id = "coreclr",
        type = "executable",
        command = vsdbgPath,
        args = { "--interpreter=vscode" },
        options = {
          externalTerminal = false,
          logging = {
            moduleLoad = false,
            trace = false,
          }
        },
        runInTerminal = false,
        reverse_request_handlers = {
          handshake = RunHandshake,
        },
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          clientID = "vscode",
          clientName = "Visual Studio Code",
          externalTerminal = true,
          console = "externalTerminal",
          repl_lang = "c_sharp",
          name = "Launch",
          request = "launch",
          program = function()
            -- Use telescope to select the dll path
            return coroutine.create(function(coro)
              local opts = {}
              require("telescope.pickers")
                  .new(opts, {
                    prompt_title = "Path to executable",
                    finder = require("telescope.finders").new_oneshot_job({
                      "fd",
                      "--no-ignore",
                      "--type", "f",
                      "--exclude", "System.*",
                      "--exclude", "Microsoft.*",
                      "--full-path", "bin/.*\\.dll$",
                    }, {}),
                    sorter = require("telescope.config").values.generic_sorter(opts),
                    attach_mappings = function(buffer_number)
                      require("telescope.actions").select_default:replace(function()
                        require("telescope.actions").close(buffer_number)
                        coroutine.resume(coro, require("telescope.actions.state").get_selected_entry()[1])
                      end)
                      return true
                    end,
                  })
                  :find()
            end)
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          type = "coreclr",
          request = "attach",
          name = "Attach",
          clientID = "vscode",
          repl_lang = "c_sharp",
          clientName = "Visual Studio Code",
          processId = function()
            return require("dap.utils").pick_process({
              prompt = "Select dotnet process",
              filter = attach_proc_filter_fn,
              label = attach_proc_label_fn
            })
          end
          -- function()
          --   return coroutine.create(function(coro)
          --     local opts = {}
          --     require("telescope.pickers").new(opts, {
          --  prompt_title = "Process ID",
          --  finder = require("telescope.finders").new_oneshot_job({ "ps", "-ax" }, {}),
          --  sorter = require("telescope.config").values.generic_sorter(opts),
          --  attach_mappings = function(buffer_number)
          --    require("telescope.actions").select_default:replace(function()
          --      require("telescope.actions").close(buffer_number)
          --      coroutine.resume(coro, require("telescope.actions.state").get_selected_entry()[1])
          --    end)
          --    return true
          --  end })
          --   end)
          --        end,
        },
      }
      -- look for launch.json in {cwd}.vscode/launch.json and use values there to override the configurations above
      -- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      --   callback = function()
      --     local vscode, _ = pcall(require, "dap.ext.vscode")
      --     if not vscode then
      --       return
      --     end
      --     require("dap.ext.vscode").load_launchjs(nil, { coreclr = { "cs" } })
      --   end,
      --   pattern = "*.vscode/*.json",
      -- })
      --require('dap.ext.vscode').load_launchjs(nil, { coreclr = {'cs'} })

      require("telescope").load_extension("dap") -- load nvim-telescope/telescope-dap.nvim
      require("overseer").patch_dap(true)        -- add support for preLaunchTask and postDebugTask in launch.json
      require("dap.ext.vscode").json_decode = require("overseer.json")
          .decode                                -- use overseer's json parser to support trailing commas

      dap.listeners.before["event_initialized"]["me"] = function()
        -- close the quickfix window when the debugger starts
        vim.api.nvim_command("cclose")
        -- close any existing dap repl
        dap.repl.close()
      end
      ---------------------------------------------------------------
      -- debugger keymaps (set a list of keymaps to be used when debugging, keep the original keymaps and restore them when debugging is finished)
      -- local keymaps_debugging = require("debugkeys").DebuggingKeymaps
      -- local api = vim.api
      -- local keymap_restore = {}
      -- local keymap_restore_global = {}
      -- local debugging_mode = false
      -- dap.listeners.after["event_initialized"]["me"] = function()
      --   -- save the original buffer specific keymaps
      --   for _, buf in pairs(api.nvim_list_bufs()) do
      --     local keymaps = api.nvim_buf_get_keymap(buf, "n")
      --     -- go through all keymaps and remove the one we want to replace
      --     for _, keymap in pairs(keymaps) do
      --       for _, dkeymap in pairs(keymaps_debugging) do
      --         if keymap.lhs == dkeymap.key then
      --           table.insert(keymap_restore, keymap)
      --           api.nvim_buf_del_keymap(buf, "n", dkeymap.key)
      --         end
      --       end
      --     end
      --   end
      --   -- add debugging keymaps:
      --   local existingkeymap = api.nvim_get_keymap("n")
      --   for _, keymap in pairs(keymaps_debugging) do
      --     -- save the original global keymaps
      --     for _, existingkey in pairs(existingkeymap) do
      --       -- print("searching keymaps", existingkey.lhs, keymap.key)
      --       if existingkey.lhs == keymap.key then
      --         -- print("existing keymap", keymap.key)
      --         table.insert(keymap_restore_global, existingkey)
      --         api.nvim_del_keymap("n", keymap.key)
      --       end
      --     end
      --     -- add the new keymaps
      --     -- print("adding keymap", keymap.key, keymap.cmd)
      --     if type(keymap.cmd) == "string" then
      --       api.nvim_set_keymap(
      --         "n",
      --         keymap.key,
      --         "<cmd>" .. keymap.cmd .. "<CR>",
      --         { silent = true, noremap = true, desc = keymap.desc }
      --       )
      --     else
      --       api.nvim_set_keymap("n", keymap.key, "", { silent = true, callback = keymap.cmd, desc = keymap.desc })
      --     end
      --   end
      --   -- require("dapui").open()
      --   dap.defaults.focus_terminal = true
      --   dap.repl.open({ height = 24 })
      --   debugging_mode = true
      -- end
      -- local function reset_keymaps()
      --   if not debugging_mode then
      --     return
      --   end
      --   -- delete debugging keymaps
      --   for _, keymap in pairs(keymaps_debugging) do
      --     api.nvim_del_keymap("n", keymap.key)
      --   end
      --   -- print("Resetting keymaps")
      --   -- restore the original buffer specfic keymaps
      --   for _, keymap in pairs(keymap_restore) do
      --     -- print("Restoring keymap for buffer", keymap.lhs, keymap.rhs)
      --     if (api.nvim_buf_is_valid(keymap.buffer)) then
      --       if type(keymap.rhs) == "string" then
      --         api.nvim_buf_set_keymap(keymap.buffer, "n", keymap.lhs, keymap.rhs, { silent = keymap.silent == 1 })
      --       else
      --         api.nvim_buf_set_keymap(
      --           keymap.buffer,
      --           "n",
      --           keymap.lhs,
      --           "",
      --           { silent = keymap.silent == 1, callback = keymap.callback }
      --         )
      --       end
      --     else
      --       -- print("Buffer is not valid", keymap.buffer)
      --     end
      --   end
      --   keymap_restore = {}
      --   -- restore the original global keymaps
      --   for _, keymap in pairs(keymap_restore_global) do
      --     -- print("Restoring keymap", keymap.lhs, keymap.rhs)
      --     if type(keymap.rhs) == "string" then
      --       api.nvim_set_keymap("n", keymap.lhs, keymap.rhs, { silent = keymap.silent == 1, noremap = false })
      --     else
      --       api.nvim_set_keymap("n", keymap.lhs, "",
      --         { silent = keymap.silent == 1, callback = keymap.callback, noremap = false })
      --     end
      --   end
      --   if dap.session() == nil then
      --     -- require("dapui").close()
      --     dap.repl.close()
      --   end
      --   debugging_mode = false
      -- end
      -- dap.listeners.after["event_terminated"]["me"] = reset_keymaps
      -- dap.listeners.after["event_exited"]["me"] = reset_keymaps
      -- end of the debugger keymaps
      ---------------------------------------------------------------
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },
}
