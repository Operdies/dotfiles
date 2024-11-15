-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup("CSharpIndent", { clear = true }),
  pattern = { "*.cs" },
  callback = function()
    vim.opt_local.filetype = "cs"
    vim.opt_local.shiftwidth = 4
  end,
})


vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup("XmlIndent", { clear = true }),
  pattern = { "*.csproj", "*.props", "*.targets" },
  callback = function()
    vim.opt_local.filetype = "xml"
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup("RestoreLastKnownCursorLine", { clear = true }),
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.fn.execute [[normal! g'"]]
    end
  end,
})
