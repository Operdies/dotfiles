--- Wrap a string to a given display width, breaking on whitespace or after a
--- dash. Widths are measured with vv.api.string_display_width(), which accounts
--- for wide characters and emoji in this environment. The string is iterated by
--- UTF-8 codepoint using the builtin utf8 library.
-- @param str string    the text to wrap
-- @param width number   maximum line display width (>= 1)
-- @param center boolean  optional; when true, pad each line with spaces on both
--                        sides so its display width equals `width` (any odd
--                        leftover space goes on the right)
-- @return table          list of wrapped lines
local function wrap(str, width, center)
    if width < 1 then width = 1 end

    local dwidth = vv.api.string_display_width

    -- Decode the string into a list of glyphs: { char = <utf8 char>, w = <width> }.
    -- One glyph per codepoint; width is cached so we only measure each once.
    -- The codepoint is kept so whitespace can be classified per-codepoint;
    -- matching "%s" on a multi-byte char is unsafe (it tests individual bytes,
    -- e.g. a byte of a CJK char can look like whitespace).
    local glyphs = {}
    for _, cp in utf8.codes(str) do
        local ch = utf8.char(cp)
        glyphs[#glyphs + 1] = { char = ch, cp = cp, w = dwidth(ch) }
    end

    -- Whitespace codepoints we treat as break/separator characters.
    local isSpace = {
        [0x09] = true, -- tab
        [0x0A] = true, -- line feed
        [0x0B] = true, -- vertical tab
        [0x0C] = true, -- form feed
        [0x0D] = true, -- carriage return
        [0x20] = true, -- space
        [0xA0] = true, -- no-break space
        [0x2028] = true, -- line separator
        [0x2029] = true, -- paragraph separator
        [0x3000] = true, -- ideographic space
    }

    -- Tokenize into words, splitting on whitespace (which is discarded) and
    -- keeping a trailing dash attached to its token so we can break after it
    -- (e.g. "foo-bar" -> "foo-" / "bar"). A token is a list of glyphs plus its
    -- total display width.
    local tokens = {}
    local cur = nil

    local function flush()
        if cur and #cur.glyphs > 0 then
            tokens[#tokens + 1] = cur
        end
        cur = nil
    end

    local function push(g)
        if not cur then cur = { glyphs = {}, w = 0 } end
        cur.glyphs[#cur.glyphs + 1] = g
        cur.w = cur.w + g.w
    end

    for _, g in ipairs(glyphs) do
        if isSpace[g.cp] then
            flush()
        else
            push(g)
            if g.cp == 0x2D then -- '-'
                flush() -- break after a dash
            end
        end
    end
    flush()

    -- Assemble tokens into lines. The current line is kept as an array of
    -- glyphs (never a string) so all logic stays codepoint-aware; we only build
    -- a string when a completed line is emitted.
    local lines = {}
    local cur = {}    -- glyphs on the current line
    local lineW = 0   -- display width of the current line
    local spaceGlyph = { char = " ", cp = 0x20, w = dwidth(" ") }

    local function glyphsToString(gs)
        local buf = {}
        for i, g in ipairs(gs) do buf[i] = g.char end
        return table.concat(buf)
    end

    local function emit()
        if #cur > 0 then
            local text = glyphsToString(cur)
            if center then
                -- Pad with spaces (display width 1) so the line is `width` wide.
                local pad = width - lineW
                if pad > 0 then
                    local left = math.floor(pad / 2)
                    text = string.rep(" ", left) .. text .. string.rep(" ", pad - left)
                end
            end
            lines[#lines + 1] = text
        end
        cur, lineW = {}, 0
    end

    local function append(gs) -- append a list of glyphs to the current line
        for _, g in ipairs(gs) do
            cur[#cur + 1] = g
            lineW = lineW + g.w
        end
    end

    local function endsWithDash()
        return #cur > 0 and cur[#cur].cp == 0x2D
    end

    -- Emit as many full-width chunks of a token's glyphs as needed when the
    -- token is wider than the whole line width (hard split on glyph boundaries).
    local function appendHardSplit(gs)
        local i = 1
        while i <= #gs do
            -- Fill the current line up to width.
            while i <= #gs and lineW + gs[i].w <= width do
                cur[#cur + 1] = gs[i]
                lineW = lineW + gs[i].w
                i = i + 1
            end
            if i <= #gs then
                -- Still glyphs left that don't fit.
                if #cur == 0 then
                    -- A single glyph wider than width: emit it alone to make
                    -- progress rather than looping forever.
                    cur[1] = gs[i]
                    lineW = gs[i].w
                    i = i + 1
                end
                emit()
            end
        end
    end

    for _, tok in ipairs(tokens) do
        if #cur == 0 then
            if tok.w <= width then
                append(tok.glyphs)
            else
                appendHardSplit(tok.glyphs)
            end
        elseif lineW + spaceGlyph.w + tok.w <= width then
            -- fits on the current line with a separating space
            append({ spaceGlyph })
            append(tok.glyphs)
        elseif endsWithDash() and lineW + tok.w <= width then
            -- previous token ended in a dash: join with no space
            append(tok.glyphs)
        else
            emit()
            if tok.w <= width then
                append(tok.glyphs)
            else
                appendHardSplit(tok.glyphs)
            end
        end
    end
    emit()

    return lines
end

-- --- Test harness -----------------------------------------------------------
-- Run this file directly (bypassing require() caching) with:
--     vv -S dev lua split.lua test
-- The harness only runs when the first argument is "test", so `require("split")`
-- and a plain `vv lua split.lua` stay quiet and just return the function.
local function test()
    local d = vv.api.string_display_width
    local function show(label, str, w, center)
        print("=== " .. label .. " (width " .. w .. ") ===")
        for _, line in ipairs(wrap(str, w, center)) do
            print(string.format("[%s] (w=%d)", line, d(line)))
        end
    end
    show("plain wrap", "the quick brown fox jumps", 10)
    show("dash break", "well-formed input-string here", 8)
    show("long word hard split", "supercalifragilistic", 6)
    show("emoji width", "hi 😀😀😀 there", 6)
    show("cjk with spaces", "世界 你好 test", 5)
    show("cjk no spaces (hard split)", "世界你好朋友", 5)
    show("single glyph wider than width", "😀😀😀", 1)
    show("empty", "", 5)
    show("only spaces", "     ", 5)
    show("trailing dash join", "a-b-c-d", 3)
    show("centered", "the quick brown fox jumps", 12, true)
    show("centered cjk/emoji", "世界 hi 😀 there", 10, true)
end

if type(arg) == "table" and arg[1] == "test" then
    test()
end

return wrap

