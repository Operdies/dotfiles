function! RealCd()
	let fname = expand('%:p')
	let realpath = system("readlink -f " .. fname)
	let realdir = fnamemodify(realpath, ":h")
	execute 'cd ' .. realdir
endfunction

function! CdGitRoot()
	call RealCd()
	execute 'cd ' .. system('git rev-parse --show-toplevel')
endfunction

function! Grephere(title, flags)
	call inputsave()
	let what = input(a:title)
	call inputrestore()
	if len(what)
		try
			execute 'vimgrep /' . what . '/' .. a:flags .. ' `git ls-files`'
			if len(getqflist()) > 0
				execute 'copen'
				execute 'wincmd p'
			endif
		catch
		endtry
	endif
endfunction

command! DoGrep silent call Grephere('grep: ', '')
command! DoFuzzyGrep silent call Grephere('fuzzy: ', 'f')

function! UpdateBufferline(abuf, del, write)
	let bufnames = filter(copy(getbufinfo()), 'v:val.listed')
	execute 'set tabline='
	let focused=bufnr()
	let newtabline = ""
	let sel = '%#TabLineSel#'
	let nosel = '%#TabLine#'
	let fill = '%#TabLineFill#'
	for b in bufnames
		" skip buffer if it was deleted
		if a:del && a:abuf == b.bufnr
			continue
		endif
		let prefix = ''
		let postfix = (b.changed ? '+' : ' ')
		if a:write && a:abuf == b.bufnr
			let postfix = ' '
		endif

		let name = prefix .. fnamemodify(b.name, ":t") .. ' [' .. b.bufnr .. ']' .. postfix

		if b.bufnr == focused
			let name = sel .. name .. nosel .. ' '
		else
			let name = nosel .. name .. ' '
		endif
		let newtabline .= name
	endfor
	let newtabline .= nosel
	execute 'set tabline=' .. fnameescape(newtabline)
endfunction

function! CompleteGitFiles(ArgLead, CmdLine, CursorPos)
	return system("git ls-files")
endfunction

function! CompleteExecutables(ArgLead, CmdLine, CursorPos)
	return system("find . -executable -type f -not -path '*/.*'")
endfunction

function! CompleteProjects(ArgLead, CmdLine, CursorPos)
	return system("ls -d ~/repos/*/ | xargs -I {} basename {}")
endfunction

function! OpenProject(project)
	execute "cd ~/repos/" .. a:project
	execute "tabe ."
endfunction

function! OldFiles(ArgLead, CmdLine, CursorPos)
	" files ending with a trailing tilde are (likely) help / man pages
	return filter(v:oldfiles, 'v:val !~ "[~]$"')->join("\n")
endfunction

command! -complete=custom,CompleteGitFiles -nargs=1 GitEdit :e <args>
command! -complete=custom,CompleteProjects -nargs=1 OpenProject :call OpenProject("<args>")
command! -complete=custom,OldFiles -nargs=1 RecentFiles :e <args>

let g:preview_balloon_settings=#{ winid: 0, text: "" }
function! PreviewBalloonExpr()
	let s = g:preview_balloon_settings
	let symbol = v:beval_text

	if s['winid'] > 0 && popup_getpos(s['winid']) != v:null
		if s['text'] == symbol
			return ""
		endif
		call popup_close(s['winid'])
	endif

	let tags = taglist($'^{symbol}$', expand('%'))
	if len(tags) == 0
		if &ft == 'vim'
			let tags = taglist($'^{symbol}()$', expand('%'))
		endif
		if len(tags) == 0
			return ""
		endif
	endif

	function! OnBalloonClosed()
		let g:preview_balloon_settings['winid'] = 0
	endfunction

	let tag = tags[0]
	let cmd = escape(tag.cmd[1:-2], '.*?/\[]~')
	let cmd = cmd->substitute('\\/', '/', 'g')
	let lines = systemlist($"grep -m 1 '{cmd}' '{tag.filename}'")
	if len(lines) == 0 || lines[0] == ""
		return ""
	endif

	let s:winid = popup_beval(lines, #{
				\ border: [],
				\ padding: [0, 1, 0, 1],
				\ scrollbar: 0,
				\ callback: { id, result -> OnBalloonClosed() },
				\ })
	let s['winid'] = s:winid
	let s['text'] = symbol

	let ext = fnamemodify(tag.filename, ':e')
	if ext != ""
		let extmap = #{
					\ h: 'c',
					\ }
		if extmap->has_key(ext)
			let ext = extmap[ext]
		endif
		call setbufvar(winbufnr(s:winid), '&ft', ext)
	endif
	return ""
endfunction

let g:PreviewSymbolSettings = { "nth": 0, "cword": "", "context": 10 }
function! s:PreviewSymbol(...)
	let s = g:PreviewSymbolSettings
	let args = get(a:, 1, #{})
	let cword = expand(get(args, "word", s['cword']))
	let cnt = get(args, "count", 1)
	let close = get(args, "close", 0)

	if close 
		if g:tagpreviewwin != 0
			call popup_close(g:tagpreviewwin)
			let g:tagpreviewwin=0
		endif
		return
	endif

	let tags = taglist($'^{cword}$', expand('%'))

	if len(tags) == 0
		if &ft == 'vim'
			let tags = taglist($'^{cword}()$', expand('%'))
		endif
		if len(tags) == 0
			echohl ErrorMsg | echo "Tag not found: " .. cword | echohl None
			return
		endif
	endif

	if s['cword'] == cword
		let s['nth'] = (s['nth'] + len(tags) + cnt) % len(tags)
	else
		let s['nth'] = 0
		let s['cword'] = cword
	endif

	let tag = tags[s['nth']]
	echo $'{cword}: tag {s['nth']+1}/{len(tags)}'
	keeppatterns keepmarks call PopupPreviewSymbol(tag)
endfunction

command! -complete=tag -nargs=1 PopupSymbol  call s:PreviewSymbol( { "word": <q-args> } )
command! -complete=tag -nargs=1 NPopupSymbol call s:PreviewSymbol( { "word": <q-args> } )
command! -complete=tag -nargs=1 PPopupSymbol call s:PreviewSymbol( { "word": <q-args>, "count": -1 } )
command!               -nargs=0 CPopupSymbol call s:PreviewSymbol( { "close" : 1 } )

let g:tagpreviewwin=0
function! PopupPreviewSymbol(tag)
	let view = winsaveview()
	let here = getpos('.')
	let buf = bufnr()
	try
		let tag = a:tag
		let tagbuf = bufadd(tag.filename)
		execute 'keepjumps silent b! ' .. tagbuf
		let cmd = escape(tag.cmd[1:-2], '.*?/\[]~')
		call cursor(1,1)
		let lineno = search(cmd, 'cn')

		if lineno == 0
			echohl ErrorMsg | echo "found tag, but tag.cmd yielded no results: " .. tag.cmd .. ' in ' .. tag.filename | echohl None
			return
		endif
	catch
		echo v:exception
		return
	finally
		execute 'keepjumps silent b! ' .. buf
		call setpos('.', here)
		call winrestview(view)
	endtry

	let context= get(g:PreviewSymbolSettings, "context", 10)
	let firstline = max([lineno - 3, 1])

	if g:tagpreviewwin != 0
		call popup_close(g:tagpreviewwin)
	endif

	let g:tagpreviewwin = popup_create(tagbuf, #{
				\ border: [],
				\ col: &columns - 3,
				\ cursorline: 1,
				\ firstline: firstline,
				\ line: 3,
				\ zindex: 1,
				\ maxheight: context,
				\ maxwidth: 80,
				\ minheight: 6,
				\ minwidth: 40,
				\ padding: [0, 1, 0, 1],
				\ pos: "topright",
				\ scrollbar: 0,
				\ title: $'{tag.filename}:{lineno}'
				\ })

	" 'cursorline' highlights the selected line, but it also sets the selected
	" line to the first line of the popup
	call win_execute(g:tagpreviewwin, lineno)
	" call win_execute(popupwin, 'normal zz')
endfunction

" open tag in preview window
command! -nargs=+ PreviewSymbol call PreviewSymbol(<args>)

function! CommentLines(context = {}, type = '') abort
	if a:type == ''
		let context = #{
					\ dot_command: v:false,
					\ extend_block: '',
					\ virtualedit: [&l:virtualedit, &g:virtualedit],
					\ }
		let &operatorfunc = function('CommentLines', [context])
		set virtualedit=block
		return 'g@'
	endif

	let save = #{
				\ virtualedit: [&l:virtualedit, &g:virtualedit],
				\ }

	let commentstring="// "
	let commentstrings = #{
				\ vim: '" ',
				\ c: '// ',
				\ cpp: '// ',
				\ conf: '# ',
				\ sh: '# ',
				\ zsh: '# ',
				\ }
	if commentstrings->has_key(&filetype)
		let commentstring = commentstrings[&filetype]
	endif

	try
		let [_, startline, _, _] = getpos("'[")
		let [_, endline, _, _] = getpos("']")
		let commentidx = 999

		let first_line = getline('.')
		let is_comment = first_line->match('^\s*' .. commentstring) >= 0
		if is_comment
			execute startline .. ',' .. endline .. 's:' .. commentstring .. '::'
		else
			for lineno in range(startline, endline)
				let line = getline(lineno)
				if line->match('^\s*$') >= 0
					continue
				endif
				let matchidx = line->match('[^ 	]')
				if matchidx >= 0 && matchidx < commentidx
					let commentidx = matchidx
				endif
			endfor
			execute startline .. ',' .. endline .. 's:^\(\s\{' .. commentidx .. '\}\):\1' .. commentstring .. ':'
		endif
	finally
		let [&l:virtualedit, &g:virtualedit] = get(a:context.dot_command ? save : a:context, 'virtualedit')
		let a:context.dot_command = v:true
	endtry
endfunction

function! AsyncRunMegaMaker()
	let makefile=''

	if filereadable(getcwd() .. '/Makefile')
		let makefile = getcwd()
	else
		let filedir = expand('%:h')
		if filedir == '.'
			let filedir = getcwd()
		endif
		if filedir[0] == '/'
			while filedir != '/'
				if filereadable(filedir .. '/Makefile')
					let makefile = filedir
					break
				endif
				let filedir = fnamemodify(filedir, ':h')
			endwhile
		endif
	endif
	if makefile == ''
		echohl ErrorMsg | echo "No makefile found." | echohl None
		return
	endif
	execute 'AsyncRun! -cwd=' .. makefile .. ' make --quiet'
endfunction

function! TmuxWinCmd(direction)
	if winnr(a:direction) != winnr()
		execute 'wincmd ' .. a:direction
	else
		let tmux_dir = #{
					\	h: 'L', 
					\ j: 'D', 
					\ k: 'U', 
					\ l: 'R'
					\ }[a:direction]
		call system('tmux select-pane -' .. tmux_dir)
	endif
endfunction

function! CleanBufferList()
	try
		let project_root = system('git rev-parse --show-toplevel')
	catch
		let project_root = getcwd()
	endtry
	let bufnames = filter(copy(getbufinfo()), 'v:val.listed')
	let todelete = ''
	for buf in bufnames
		if buf.changed == 0 && len(buf.windows) == 0 && buf.name->match('^' .. project_root) != 0 
			let todelete ..= ' ' .. buf.bufnr
		endif
	endfor
	if todelete != ''
		execute 'bdelete' .. todelete
	endif
endfunction

let g:DebuggerLayout = #{
			\ height: 10,
			\ width: 60,
			\ layout: 'tall',
			\ }
function s:StartDebugger(file)
	" open the current file in a new tab and configure the window layout for debugging
	let here = getpos('.')
	let options = g:DebuggerLayout
	tabedit %
	call setpos('.', here)
	let src_w = win_getid(winnr())
	execute 'Termdebug ' .. a:file
	let gdb_w = win_getid(winnr())
	wincmd w
	let prg_w = win_getid(winnr())
	if options['layout'] == 'tiled'
		" ┌─────────────┬─────┐
		" │             │     │
		" │   source    │     │
		" │             │ gdb │
		" ├─────────────┤     │
		" │   program   │     │
		" └─────────────┴─────┘
		" select the Program window and anchor it to the bottom with fixed height
		call win_gotoid(prg_w)
		wincmd J
		execute 'resize ' .. options['height']
		set winfixheight nobuflisted
		call win_gotoid(gdb_w)
		wincmd L
		execute 'vertical resize ' .. options['width']
		set winfixwidth nobuflisted
	elseif options['layout'] == 'tall'
		" select the Gdb window and anchor it to the right with fixed width
		" ┌────┬────────┬─────┐
		" │    │        │     │
		" │    │        │     │
		" │prog│ source │ gdb │
		" │ram │        │     │
		" │    │        │     │
		" └────┴────────┴─────┘
		call win_gotoid(prg_w)
		wincmd H
		set winfixwidth nobuflisted
		execute 'vertical resize ' .. options['width']
		call win_gotoid(gdb_w)
		wincmd L
		set winfixwidth nobuflisted
		execute 'vertical resize ' .. options['width']
	else " wide
		" ┌───────────────────┐
		" │                   │
		" │      source       │
		" │                   │
		" ├─────────┬─────────┤
		" │   gdb   │ program │
		" └─────────┴─────────┘
		" Move the Gdb and Program window side by side
		call win_gotoid(gdb_w)
		wincmd H
		" Move the Source window to the top
		call win_gotoid(src_w)
		wincmd K
		" Fix the height of the Gdb and Program windows
		call win_gotoid(gdb_w)
		execute 'resize ' .. options['height']
		set winfixheight nobuflisted
		call win_gotoid(prg_w)
		set winfixheight nobuflisted
	endif
	call setbufvar('gdb communication', '&buflisted', 0)
	call win_gotoid(src_w)
endfunction

function! s:CompleteGdb(ArgLead, CmdLine, CursorPos)
	let partial_line = a:CmdLine[0:a:CursorPos]
	let words = partial_line->split()
	let n = len(words)
	if a:CmdLine[a:CursorPos-1] == ' '
		let n += 1
	endif

	if n == 2
		return [ 'backtrace', 'print', 'display', 'undisplay', 'x/nfu', 'thread', 'set', 'info', 'whatis', 'quit' ]->join("\n")
	endif

	let cont = #{
				\ info: ['args', 'breakpoints', 'display', 'locals', 'sharedlibrary', 'signals', 'threads', 'directories', 'listsize'],
				\ }
	if n == 3 && cont->has_key(words[1])
		return cont[words[1]]->join("\n")
	endif
	return ""
endfunction

let g:active_toasts = []

function! Toast(what, ...)
	let what_str = a:what
	let s:msgheight = 3
	let time = get(a:, 1, 3000)
	if type(a:what) != type("") && type(a:what) != type([])
		let what_str = string(a:what)
	endif

	function! RemoveToast(id)
		let idx = g:active_toasts->index(a:id)
		call remove(g:active_toasts, idx)
		for i in range(idx, len(g:active_toasts)-1)
			let t = g:active_toasts[i]
			call popup_move(t, #{ line: (i+1) * s:msgheight })
		endfor
	endfunction

	let toast_id = popup_create(what_str, #{
				\ line: (1 + len(g:active_toasts)) * s:msgheight,
				\ col: &columns - 3,
				\ padding: [0, 1, 0, 1],
				\ border: [],
				\ time: time,
				\ zindex: 10,
				\ pos: "topright",
				\ callback: { id, result -> RemoveToast(id) },
				\ })
	let g:active_toasts += [toast_id]
endfunction

function! s:Snipe(forwards)
	let ESCAPE = 27
	echo
	echon "Snipe: "
	let ch1 = getchar()
	if ch1 == ESCAPE
		return
	endif
	let s1 = nr2char(ch1)
	echon s1
	let ch2 = getchar()
	if ch2 == ESCAPE
		return
	endif
	let s2 = nr2char(ch2)
	echon s2
	let chars = (s1 .. s2)->escape('\')
	let flags = a:forwards ? 'zWs' : 'bzWs'
	" let n = search('\V' .. chars, flags)
	let m = v:count ? v:count : 1
	for i in range(1, m)
		if search('\V' .. chars, flags) == 0
			return
		endif
	endfor
	" if n == 0
	" 	echohl ErrorMsg | echo "No match: " .. chars | echohl None
	" endif
endfunction

command! Snipe call s:Snipe(1)
command! BSnipe call s:Snipe(0)

command! -complete=custom,CompleteExecutables -nargs=1 Debug call s:StartDebugger('<args>')
command! -complete=custom,s:CompleteGdb -nargs=+ GdbDo call TermDebugSendCommand('<args>')

defcompile
call popup_clear()
