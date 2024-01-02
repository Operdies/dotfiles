function! RealCd()
	let fname = expand('%:p')
	let realpath = system("readlink -f " .. fname)
	let realdir = fnamemodify(realpath, ":h")
	execute 'cd ' .. realdir
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
	let files = systemlist("git ls-files")
	return filter(files, 'stridx(v:val, a:ArgLead) != -1')
endfunction

function! CompleteProjects(ArgLead, CmdLine, CursorPos)
	let files = systemlist("ls -d ~/repos/*/ | xargs -I {} basename {}")
	return filter(files, 'stridx(v:val, a:ArgLead) != -1')
endfunction

function! OpenProject(project)
	execute "cd ~/repos/" .. a:project
	execute "e ."
endfunction

function! OldFiles(ArgLead, CmdLine, CursorPos)
	let files = copy(v:oldfiles)
	let nontemp = filter(files, 'v:val !~ "[~]$"')
	let matching = filter(nontemp, 'stridx(v:val, a:ArgLead) != -1')
	return matching
endfunction

command! -complete=customlist,CompleteGitFiles -nargs=1 GitEdit :e <args>
command! -complete=customlist,CompleteProjects -nargs=1 OpenProject :call OpenProject("<args>")
command! -complete=customlist,OldFiles -nargs=1 RecentFiles :e <args>

let g:CurrentPreviewSymbol=''
function! PreviewSymbol(arg, dir)
	let cword = expand('<cword>')
	try
		let preview_window=popup_findpreview()
		if preview_window == 0 || g:CurrentPreviewSymbol != cword
			execute "silent wincmd }"
			let g:CurrentPreviewSymbol = cword
		else
			let preview_buf = winbufnr(preview_window)
			if a:dir == '0'
				try
					execute "ptnext"
				catch
					execute "silent! ptfirst"
				endtry
			else
				try
					execute "ptprev"
				catch
					execute "silent! ptlast"
				endtry
			endif
			if winbufnr(preview_window) != preview_buf && getbufvar(preview_buf, "&readonly")
				execute "bdelete " . preview_buf
			endif
		endif
		return
	catch
		echohl ErrorMsg | echo "Tag not found: " .. expand("<cword>") | echohl None
	endtry
endfunction

if !exists('*Preserve')
	function! Preserve(command)
		try
			" Preparation: save last search, and cursor position.
			let l:win_view = winsaveview()
			execute 'keepjumps ' . a:command
		finally
			" try restore / reg and cursor position
			call winrestview(l:win_view)
		endtry
	endfunction
endif

" open tag in preview window
command! -nargs=+ PreviewSymbol call PreviewSymbol(<f-args>)

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

function! StartDebugger(file)
	tabnew | bprev | execute 'Termdebug ' .. a:file | set winfixheight | wincmd H | wincmd p | wincmd K | execute 'resize ' .. floor(&lines * 0.7)
	Break
	Run
endfunction
command! -complete=file -nargs=1 Debug call StartDebugger('<args>')

