function! CompleteExecutables(ArgLead, CmdLine, CursorPos)
	return system("find . -executable -type f -not -path '*/.*'")
endfunction

function! CompleteProjects(ArgLead, CmdLine, CursorPos)
	let dirs = ["~/repos/", "/git/"]
	let projects = []
	for cand in dirs
		let s:dir = expand(cand)
		if isdirectory(s:dir)
			let projects += readdir(s:dir, { x -> isdirectory(s:dir .. x) })
		endif
	endfor
	return projects->join("\n")
endfunction
 
function! OpenProject(project)
	execute "cd ~/repos/" .. a:project
	execute "tabe ."
endfunction

function! OpenWizard()
	let path = input("Project: ", '', 'custom,CompleteProjects')
	if path == ''
		return
	endif
	let fullpath = expand('~/repos/' .. path)
	if !isdirectory(fullpath)
		echohl ErrorMsg
		echo "Project '" .. path .. "' not valid."
		echohl None
		return
	endif

	execute 'cd ' .. fullpath

	let file = input("File: ", '', 'custom,CompleteGitFiles')
	if file == ''
		return
	endif
	if !filereadable(file)
		echohl ErrorMsg
		echo "File '" .. file .. "' not readable."
		echohl None
		return
	endif
	execute ':e ' .. file
endfunction

function! OldFiles(ArgLead, CmdLine, CursorPos)
	" files ending with a trailing tilde are (likely) help / man pages
	return filter(v:oldfiles, 'v:val !~ "[~]$"')->join("\n")
endfunction

function! s:GitEdit(f)
	if filereadable(a:f)
		execute ':e ' .. a:f
	else
		echohl ErrorMsg
		echo "File '" .. a:f .. "' could not be opened."
		echohl None
	endif
endfunction

command! -complete=custom,CompleteGitFiles -nargs=1 GitEdit call s:GitEdit(<q-args>)
command! -complete=custom,CompleteProjects -nargs=1 OpenProject :call OpenProject("<args>")
command! -complete=custom,OldFiles -nargs=1 RecentFiles :e <args>

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

command! -complete=custom,CompleteExecutables -nargs=1 Debug call s:StartDebugger('<args>')
command! -complete=custom,s:CompleteGdb -nargs=+ GdbDo call TermDebugSendCommand('<args>')

