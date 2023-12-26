set shiftwidth=2
set tabstop=2
set noexpandtab

set autoread
set autowrite

set ignorecase
set smartcase
set nocompatible
set ruler
set showcmd
set wildmenu
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
nmap H :bprev<cr>
nmap L :bnext<cr>
nmap [<tab> :tabprev<cr>
nmap ]<tab> :tabnext<cr>
nmap <space>bd :bdelete<cr>
nmap <space>gg :silent !lazygit<cr><C-l>
nmap K :Man <cword><cr>
nmap [<space> mlO<esc>`l
nmap ]<space> mlo<esc>`l
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
function! s:UpdateBufferline(abuf, del)
	let bufnames = filter(copy(getbufinfo()), 'v:val.listed')
	execute 'set tabline='
	let focused=bufnr()
	let newtabline = ""
	let sel = '%#TabLineSel#'
	let nosel = '%#TabLine#'
	let fill = '%#TabLineFill#'
	for b in bufnames
		if a:del && a:abuf == b.bufnr
			continue
		endif
		let name = fnamemodify(b.name, ":t") . ' [' . b.bufnr . ']'
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

command! UpdateBufferline call s:UpdateBufferline()

augroup bufferlinegrp
	autocmd!
	autocmd BufEnter * call s:UpdateBufferline(expand("<abuf>"), 0)
	autocmd BufDelete * call s:UpdateBufferline(expand("<abuf>"), 1)
	autocmd BufNew * call s:UpdateBufferline(expand("<abuf>"), 0)
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
nmap <C-j> :!tcc -run %<cr>
nmap <space>fp :OpenProject 
nmap <space>fr :RecentFiles 
nmap <tab> :wincmd w<cr>
nmap <esc><tab> :wincmd W<cr>
" open tag in preview window
nmap <C-k> :wincmd }<cr>

set viminfo='30,<100,s100,:100,n~/.vim/viminfo
" set tags+=~/.cache/ctags/tags
