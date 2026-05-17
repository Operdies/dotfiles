local M = {}

--- @class Process
--- @field id integer process id
--- @field read_to_end fun(): string[], string[]
--- @field lines fun(): fun(): velvet.api.output_channel?, string? iterator
--- @field wait_for_exit fun(): integer
--- @field exitcode? integer

local Process = {}
Process.__index = Process

local function get_registrations(id)
  local when = function(_, e) return e.data.id == id end
  local on_output = { event = 'process.output', when = when }
  local on_exit = { event = 'process.exited', when = when }
  return on_output, on_exit
end

---
---Returns an iterator so the construction
---```lua
---for channel, line in process:lines() do
---    body
---end
---```
---
---will iterate over all lines produced by |process| until it exits.
---
--- @return fun(): velvet.api.output_channel?, string? Iterator read process output line by line
function Process:lines()
  if self.exitcode ~= nil then error("Process has already exited.") end
  -- experimental new concept -- coroutines as signals.
  -- Maybe the async API should make this concept available somehow?
  -- The alternative is emitting some specialized event like |velvet.process.<guid>|,
  -- but this kind of event adds noise. An anonymouse approach like this is preferable.
  -- This kind of emulates the behavior of C# waithandles.
  local new_data = vv.async.run(function() coroutine.yield() end)
  local function append_lines(tbl, str)
    local tail = tbl.tail
    local did_add = false
    for line, term in str:gmatch('([^\n]*)(\n?)') do
      term = term == '\n'
      local entry = { line = (tbl[tail] and tbl[tail].line or "") .. line, terminated = term }
      tbl[tail] = entry
      if term then tail = tail + 1 end
      did_add = did_add or term
    end
    if did_add then 
      local e = new_data
      new_data = vv.async.run(function() coroutine.yield() end)
      coroutine.resume(e)
    end
    tbl.tail = tail
    return tail
  end
  local streams = {
    stdout = { head = 1, tail = 1 },
    stderr = { head = 1, tail = 1 },
  }
  local did_exit = false
  local on_output, on_exit = get_registrations(self.id)
  -- we must stream events independently from the iterator function.
  -- otherwise, consumers can miss output by calling other async functions while
  -- processing output.
  local reader_thread = vv.async.run(function()
    for reg, evt in vv.async.stream(on_output, on_exit) do
      if reg == on_exit then
        did_exit = true
        self.exitcode = evt.data.exit_code
        break
      else
        append_lines(streams[evt.data.channel], evt.data.output)
      end
    end
  end)

  local function next()
    for channel, tbl in pairs(streams) do
      local cur = tbl[tbl.head]
      if cur and (cur.terminated or did_exit) then
        local line = cur.line
        tbl[tbl.head] = nil
        tbl.head = tbl.head + 1
        return channel, line
      end
    end
    if did_exit then return nil end
    vv.async.wait(new_data, reader_thread)
    return next()
  end

  return function()
    local channel, output = next()
    return channel, output
  end
end

--- wait for process to exit and return all output
--- @return string stdout, string stderr
function Process:read_to_end()
  if self.exitcode ~= nil then error("Process has already exited.") end
  local streams = {stdout = {}, stderr = {}}
  local on_output, on_exit = get_registrations(self.id)
  for reg, evt in vv.async.stream(on_output, on_exit) do
    if reg == on_exit then 
      self.exitcode = evt.data.exit_code
      break
    end
    local s = streams[evt.data.channel]
    s[#s+1] = evt.data.output
  end
  return table.concat(streams.stdout, ''), table.concat(streams.stderr, '')
end

--- wait for |self| to exit.
--- @return integer status
function Process:wait_for_exit()
  local _, on_exit = get_registrations(self.id)
  local _, e = vv.async.wait(on_exit)
  self.exitcode = e.data.exit_code
  return self.exitcode
end

--- kill this process
function Process:kill()
  if self.exitcode ~= nil then error("Process has already exited.") end
  vv.api.process_kill(self.id)
end

--- @class velvet.process.options : velvet.api.process.spawn_options
--- @field on_stdout? fun(process: Process, data: string) callback called when the process produces output
--- @field on_stderr? fun(process: Process, data: string) callback called when the process produces errors
--- @field on_exit? fun(process: Process, status: integer) callback called when the process exits
--- @field stdin? string input provided as stdin on startup

--- wrap process |p| to make the high level facilities available
--- Output generated before wrapping the process is lost.
--- @param options? velvet.process.options spawn options
function M.wrap(p, options)
  options = options or {}
  local instance = setmetatable({ id = p }, Process)
  local on_output, on_exit = get_registrations(p)
  vv.async.run(function()
    local streams = { stdout = options.on_stdout or function() end, stderr = options.on_stderr or function() end }
    if not options.on_stdout and not options.on_stderr then on_output = nil end
    for reg, evt in vv.async.stream(on_exit, on_output) do
      if reg == on_exit then
        instance.exitcode = evt.data.exit_code
        if options.on_exit then options.on_exit(instance, instance.exitcode) end
        return
      else
        streams[evt.data.channel](instance, evt.data.output)
      end
    end
  end)
  return instance
end

--- spawn a new process
--- @param cmd string|string[] process to spawn
--- @param options? velvet.process.options spawn options
function M.spawn(cmd, options)
  options = options or {}
  local p = vv.api.process_spawn(cmd, {
    environment = options.environment or nil,
    working_directory = options.working_directory or nil,
    stderr_mode = options.stderr_mode or 'stream',
    stdout_mode = options.stdout_mode or 'stream',
    stdin_mode = options.stdin_mode or (options.stdin and 'stream' or 'none')
  })
  if options.stdin then
    vv.api.process_stdin_write(p, options.stdin)
    if options.stdin_mode ~= 'stream' then
      vv.api.process_stdin_close(p)
    end
  end
  return M.wrap(p, options)
end

return M
