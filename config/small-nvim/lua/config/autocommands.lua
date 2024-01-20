local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("CsharpAsXml"),
  pattern = { "*.cs" },
  callback = function() 
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("CsharpIndent"),
  pattern = { "*.csproj", "*.props" },
  callback = function() 
    vim.opt_local.filetype = "xml"
    vim.opt_local.shiftwidth = 4
  end,
})

