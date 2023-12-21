set hlsearch
set shiftwidth=2
set tabstop=2
set noexpandtab

set ignorecase
set smartcase
set nocompatible
set ruler
set showcmd
set wildmenu
set wildmode=full

set number
set foldmethod=syntax
set foldlevel=99
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

nmap <C-q> :w<cr>:make!<cr>
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
nmap <C-j> :m .+1<cr>==
nmap <C-k> :m .-2<cr>==
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
