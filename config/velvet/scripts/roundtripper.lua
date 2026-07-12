local function roundtrip_cells(cells)
  local strs = {}
  for _, c in ipairs(cells) do
    local esc = "\x1b["
    local function iconv(f) return math.floor(f * 255) end
    local function tblstr2(tbl, fg)
      if not tbl then return '' end
      local inner = table.concat({ fg and 38 or 48, 5, tbl }, ';')
      return table.concat({ esc, inner, 'm' })
    end
    local function colstr(rgb, fg)
      if not rgb then return "" end
      local inner = table.concat({ fg and 38 or 48, 2, iconv(rgb.red), iconv(rgb.green), iconv(rgb.blue) }, ';')
      return table.concat({ esc, inner, 'm' })
    end

    if c.style then
      local s = c.style
      local styles = {}
      for shift = 1, 31 do
        local bitmask = 1 << (shift - 1)
        if s & bitmask == bitmask then
          styles[#styles + 1] = tostring(shift)
        end
      end
      if #styles > 0 then
        local inner = table.concat(styles, ';')
        strs[#strs + 1] = table.concat({ esc, inner, 'm' })
      end
    end

    if c.content then
      strs[#strs + 1] = colstr(c.foreground.rgb, true)
      strs[#strs + 1] = colstr(c.background.rgb, false)
      strs[#strs + 1] = tblstr2(c.foreground.table, true)
      strs[#strs + 1] = tblstr2(c.background.table, false)
      strs[#strs + 1] = c.content
      strs[#strs + 1] = "\x1b[m"
    end
  end
  return table.concat(strs, '')
end

--- @param id integer window id
local function cell_roundtrip_example(id)
  local g = vv.api.window_get_geometry(id)
  g.left = 1; g.top = 1
  local tgrid = vv.api.window_get_cells(id, g)
  local all = {}
  for _, line in ipairs(tgrid) do
    all[#all + 1] = roundtrip_cells(line.cells)
  end
  all[1] = "\x1b[H\x1b[2J\x1b[3J" .. all[1]
  print(table.concat(all, '\n'))
end

-- if arg1 is a valid window id then assume we are running in script mode
if arg[1] then
  local id = tonumber(arg[1])
  if id and vv.api.window_is_valid(id) then
    cell_roundtrip_example(id)
  end
  return nil
end

-- otherwise act like a normal module
return {
  print_window = cell_roundtrip_example,
}
