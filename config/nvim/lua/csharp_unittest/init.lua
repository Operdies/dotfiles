local M = { }

local query = vim.treesitter.query.parse('c_sharp', [[
(class_declaration
  name: (identifier) @class.name
  body: 
  (declaration_list  
    (method_declaration
      (attribute_list
        (attribute
          name: (identifier) @_attr_name
          (#any-of? @_attr_name "Test" "TestCase")
        )
      )
      name: (identifier) @test.method.name
    ) @test.method
  )
)
]])

-- local query = vim.treesitter.query.parse('c_sharp', [[
--   (method_declaration
--     (attribute_list
--       (attribute
--         name: (identifier) @_attr_name
--         (#any-of? @_attr_name "Test" "TestCase")
--       )
--     )
--     name: (identifier) @test.method.name
--   ) @test.method
-- ]])

local function get_test_under_cursor()
  local tree = vim.treesitter.get_parser():parse()[1]
  local captures = query:iter_captures(tree:root(), 0)
  local row = vim.fn.getcurpos()[2] - 1

  for _, match, _ in query:iter_matches(tree:root(), 0, -1) do
    local test_definition = {}
    local inside = false

    for id, nodes in pairs(match) do
      local name = query.captures[id] -- capture name
      local node = nodes[1]
      if name == "test.method" then
        local row1, col1, row2, col2 = vim.treesitter.get_node_range(node)
        if row1 <= row and row2 >= row then
          inside = true
          test_definition.range = { row1 + 1, row2 + 1 }
        end
      end
      if name == "test.method.name" then
        test_definition.methodName = vim.treesitter.get_node_text(node, 0)
      end
      if name == "class.name" then
        test_definition.className = vim.treesitter.get_node_text(node, 0)
      end
    end

    if inside then
      return test_definition
    end
  end
  return nil
end


local prev_test_name = nil
local prev_test = {
  project = nil,
  name = nil,
}


local function debug_current_test()
  local dap = require('dap')
  local test = prev_test
  local current_test = get_test_under_cursor()
  local testname = current_test and current_test.methodName
  if testname ~= nil then
    test = { name = testname, project = vim.fn.expand('%:h') }
  end
  if test.name == nil then return end
  prev_test = test
  local attached = false
  local bufname = test.project .. " -- " .. test.name
  print("Debugging " .. bufname)
  local outbuf = vim.fn.bufnr(bufname)
  if outbuf == -1 then
    outbuf = vim.api.nvim_create_buf(true, true)
  end
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = outbuf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = outbuf })
  vim.api.nvim_buf_set_name(outbuf, bufname)
  vim.api.nvim_buf_set_lines(outbuf, 0, -1, false, {})

  local jobargs = { "dotnet", "test", test.project, "--filter", test.name }
  local job = vim.fn.jobstart(jobargs, {
    on_stderr = function(t, v)
      vim.api.nvim_buf_set_lines(outbuf, -2, -1, false, v)
    end,
    on_stdout = function(t, v) 
      vim.api.nvim_buf_set_lines(outbuf, -2, -1, false, v)
      if attached then return end
      for _, line in ipairs(v) do
        local pid = line:match("Process Id: (%d+)")
        if pid ~= nil then
          local num = tonumber(pid)
          if num ~= nil then
            attached = true
            dap.run({
              type = 'coreclr',
              request = 'attach',
              processId = num,
              name = test.name,
            })
            return
          end
        end
      end
    end,
    stdout_buffered = false,
    env = {
      ["VSTEST_HOST_DEBUG"] = "1",
    },
  })

  -- kill the task after a minute if we never attached
  vim.uv.new_timer():start(60000, 0, vim.schedule_wrap(function()
    if not attached then
      vim.fn.jobstop(job)
    end
  end))
end


M.setup = function(opts)
  local augroup = vim.api.nvim_create_augroup('cshar-unittest-autocommands', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    pattern = { "*.cs" },
    callback = function()
      vim.keymap.set('n', 'grt', function() debug_current_test() end, { buffer = vim.fn.bufnr(), desc = "Debug Test Under Cursor" })
    end,
  })
  -- vim.api.nvim_create_autocmd('CursorMoved', {
  --   group = augroup,
  --   pattern = { "*.cs" },
  --   callback = function()
  --     local current = get_test_under_cursor()
  --     if current ~= nil then
  --       print(vim.inspect(current, { newline = ' ', indent = ''}))
  --     end
  --   end,
  -- })
end

return M
