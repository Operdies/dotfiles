﻿set nocompatible

set shiftwidth=2
set tabstop=2
set noexpandtab

" set autoread
" set autowrite
" set hidden

set ignorecase
set smartcase
set tagcase=match
set ruler
set showcmd
set wildmenu
set hlsearch
" first tab: list files. Second tab: cycle matches
set wildmode=list,full

set number
" set foldmethod=syntax
" set foldlevel=99
" close all folds
nmap zC :setlocal foldlevel=0<cr>
" open all folds
nmap zO :setlocal foldlevel=99<cr>

set ttimeout
set ttimeoutlen=100

set display=truncate
set scrolloff=5
set incsearch
" exclude octals from <C-a> / <C-x>
set nrformats-=octal

nmap <C-s> :w<cr>
nmap H :bprev!<cr>
nmap L :bnext!<cr>
nmap [<tab> :tabprev<cr>
nmap ]<tab> :tabnext<cr>
nmap <space>bd :bdelete<cr>
nmap <space>gg :silent !lazygit<cr><C-l>
nmap K :Man <cword><cr>
nmap [<space> m'O<esc>`'
nmap ]<space> m'o<esc>`'
nmap <space>y "+
nmap gp `[v`]
vmap < <gv
vmap > >gv
" nmap <C-j> :m .+1<cr>==
" nmap <C-k> :m .-2<cr>==
vmap <C-j> :m '>+1<cr>gv=gv
vmap <C-k> :m '<-2<cr>gv=gv

" create an undo point before pasting
inoremap <C-r> <C-G>u<C-r>

set noswapfile
set nobackup

let $PAGER=''

set undofile
packadd! matchit
packadd! termdebug

autocmd FileType text setlocal textwidth=80

filetype plugin indent on
syntax on
let c_comment_strings=1
set mouse=nvi

autocmd BufReadPost *
			\ let line = line("'\"")
			\ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
			\      && index(['xxd', 'gitrebase'], &filetype) == -1
			\ |   execute "normal! g`\""
			\ | endif

set termguicolors
colorscheme catppuccin_mocha

nmap <space>o :e %:p:h<cr>
nmap <space>cd :cd %:p:h<cr>
nmap <space>fw /\<

nmap ]q :cnext<cr>
nmap [q :cprev<cr>

nmap [g :lprev<cr>
nmap ]g :lnext<cr>

" indent text after pasting
nmap p p`[v`]=
nmap P P`[v`]=

function! s:Grephere(title, flags)
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

command! DoGrep silent call s:Grephere('grep: ', '')
command! DoFuzzyGrep silent call s:Grephere('fuzzy: ', 'f')

nmap <space>fg :silent DoGrep<cr>
nmap <space>fG :silent DoFuzzyGrep<cr>
nmap <space>qf :copen<cr>
nnoremap <esc> :silent nohlsearch<cr><esc>

function! s:SilentMake()
	let success = 1
	execute 'cclose'
	execute 'silent !make --quiet > make.err 2>&1'
	execute 'cfile make.err'
	if len(getqflist()) > 0
		let success = 0
		execute 'copen'
		execute 'nnoremap <buffer> q :cclose<cr>'
		execute 'wincmd p'
	else
	endif

	execute 'redraw!'

	if success
		echo "Build Succeeded"
	else
		echo "Build Failed"
	endif
endfunction

command! SilentMake call s:SilentMake()

nmap <C-q> :wa<cr>:SilentMake<cr>

nmap gb :ls<cr>:b<space>
nmap <space>fb :ls<cr>:b<space>

set showtabline=2
function! s:UpdateBufferline(abuf, del, write)
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
		let prefix = ' '
		if b.changed
			let prefix = '+'
		endif
		if a:write && a:abuf == b.bufnr
			let prefix = ' '
		endif
		let name = prefix . fnamemodify(b.name, ":t") . ' [' . b.bufnr . ']' . ' '
		if b.bufnr == focused
			let name = sel . name . nosel . ' '
		else
			let name = nosel . name . ' '
		endif
		let newtabline .= name
	endfor
	let newtabline .= nosel
	execute 'set tabline=' .. fnameescape(newtabline)
endfunction

augroup bufferlinegrp
	autocmd!
	autocmd BufEnter,BufNew * call s:UpdateBufferline(expand("<abuf>"), 0, 0)
	autocmd BufDelete * call s:UpdateBufferline(expand("<abuf>"), 1, 0)
	autocmd BufWrite * call s:UpdateBufferline(expand("<abuf>"), 0, 1)
augroup END


augroup qf
	autocmd!
	autocmd FileType qf set nobuflisted
	autocmd FileType qf nnoremap <buffer> q :cclose<cr>
augroup END

augroup help2
	autocmd!
	autocmd FileType help set nobuflisted
	autocmd FileType help nnoremap <buffer> q :bdel<cr>
augroup END

augroup netrw
	autocmd!
	autocmd FileType netrw set nobuflisted
	autocmd FileType netrw nnoremap <buffer> q :bdel<cr>
augroup END

nmap <space>so :w<cr>:so %<cr>

function! s:CompleteGitFiles(ArgLead, CmdLine, CursorPos)
	let files = systemlist("git ls-files")
	return filter(files, 'stridx(v:val, a:ArgLead) != -1')
endfunction

function! s:CompleteProjects(ArgLead, CmdLine, CursorPos)
	let files = systemlist("ls -d ~/repos/*/ | xargs -I {} basename {}")
	return filter(files, 'stridx(v:val, a:ArgLead) != -1')
endfunction

function! s:OpenProject(project)
	execute "cd ~/repos/" .. a:project
	execute "e ."
endfunction

function! s:OldFiles(ArgLead, CmdLine, CursorPos)
	let files = copy(v:oldfiles)
	let nontemp = filter(files, 'v:val !~ "[~]$"')
	let matching = filter(nontemp, 'stridx(v:val, a:ArgLead) != -1')
	return matching
endfunction

command! -complete=customlist,s:CompleteGitFiles -nargs=1 GitEdit :e <args>
command! -complete=customlist,s:CompleteProjects -nargs=1 OpenProject :call s:OpenProject("<args>")
command! -complete=customlist,s:OldFiles -nargs=1 RecentFiles :e <args>

map <space>ff :GitEdit 
nmap <space>cr :!tcc -run %<cr>
nmap <space>fp :OpenProject 
nmap <space>fr :RecentFiles 
" nmap <tab> :wincmd w<cr>
" nmap <esc><tab> :wincmd W<cr>

set previewpopup=height:10,width:100,border:off

function! s:PreviewSymbol(arg, dir)
	function! Cleanup()
		let preview_window=popup_findpreview()
		let preview_buf = winbufnr(preview_window)
		let readonly = getbufvar(preview_buf, "&readonly")
		pclose
		if readonly
			execute "silent! bdelete " . preview_buf
			call s:UpdateBufferline(0,0,0)
		endif
	endfunction

	let preview_window=popup_findpreview()
	if preview_window == 0
		execute "silent wincmd }"
	else
		let preview_buf = winbufnr(preview_window)
		let readonly = getbufvar(preview_buf, "&readonly")
		if a:dir == '0'
			execute "silent! ptnext"
		else
			execute "silent! ptprev"
		endif
		if readonly
			execute "silent! bdelete " . preview_buf
		endif
	endif
	if a:arg == "i"
		autocmd InsertLeave * ++once call Cleanup()
	else
		autocmd CursorMoved * ++once call Cleanup()
	endif
endfunction
" open tag in preview window
command! -nargs=+ PreviewSymbol call s:PreviewSymbol(<f-args>)
nmap <C-k> <cmd>PreviewSymbol n 1<cr>
imap <C-k> <C-c>:PreviewSymbol i 1<cr>gi
nmap <C-j> <cmd>PreviewSymbol n 0<cr>
imap <C-j> <C-c>:PreviewSymbol i 0<cr>gi

" set updatetime=2000
augroup autopreview
	autocmd!
	" autocmd CursorHold,CursorHoldI * PreviewSymbol
augroup END

set viminfo='100,<100,s100,:100,n~/.vim/viminfo
set tags+=~/.cache/ctags/tags

if !exists('*Preserve')
    function! Preserve(command)
        try
            " Preparation: save last search, and cursor position.
            let l:win_view = winsaveview()
            let l:old_query = getreg('/')
            silent! execute 'keepjumps' . a:command
        finally
            " try restore / reg and cursor position
            call winrestview(l:win_view)
            call setreg('/', l:old_query)
        endtry
    endfunction
endif

highlight ExtraWhitespace ctermbg=lightblue guibg=lightblue
match ExtraWhitespace /\s\+$/
nnoremap <space>cw <cmd>call Preserve('%s/\s\+$//')<cr>
tmap <esc><esc> <C-w>N
