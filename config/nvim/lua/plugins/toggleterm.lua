return {
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = {
      { "<C-\\>",     desc = "toggleterm" },
      { "<leader>gg", desc = "lazygit", },
    },
    opts = {
      direction = "float",
      size = 20,
      open_mapping = "<C-\\>",
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = false,
      persist_size = true,
      persist_mode = false,
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
      },
      autochdir = true,
      env = {
        EDITOR = "nvr -l",
      },
    },
    config = function(_, opts)
      if 'Windows_NT' == vim.loop.os_uname().sysname then
        vim.cmd [[
            let &shell = 'powershell'
            let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
            let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
            let &shellpipe  = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
            set shellquote= shellxquote=
            ]]
      end

      opts.shell = vim.o.shell
      local toggleterm = require("toggleterm")
      toggleterm.setup(opts)

      local lazygit = require("toggleterm.terminal").Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        on_open = function(term)
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-q>", '<cmd>close<cr>', { noremap = true, silent = true })
        end,
      })
      vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "lazygit" })
    end,
  },
}
