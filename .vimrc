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
set wildmode=full

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
nmap L :bprev<cr>
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

set autochdir

function! s:Grephere()
	call inputsave()
	let what = input("vimgrep: ")
	call inputrestore()
	if len(what)
		try
			execute 'vimgrep /' . what . '/j `git ls-files`'
			if len(getqflist()) > 0
				execute 'copen'
				execute 'wincmd p'
			endif
		catch
		endtry
	endif
endfunction

command! DoGrep silent call s:Grephere()

nmap <space>fg :silent DoGrep<cr>
nmap <space>qf :copen<cr>
nnoremap <esc> :silent nohlsearch<cr><esc>

function! s:SilentMake()
	let success = 1
	execute 'cclose'
	execute 'silent !make --quiet > make.err 2>&1'
	execute 'silent !ctags `git ls-files` --c-kinds=+p'

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
nmap <space>fb :b 

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

function! s:MyFunc(ArgLead, CmdLine, CursorPos)
	let files = systemlist("git ls-files")
	return filter(files, 'stridx(v:val, a:ArgLead) != -1')
endfunction

command -complete=customlist,s:MyFunc -nargs=1 GitEdit :e <args>

