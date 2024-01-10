set nocompatible
set shiftwidth=2
set tabstop=2
set noexpandtab
set ignorecase
set smartcase
set tagcase=match
set ruler
set showcmd
set wildmenu
set hlsearch
" first tab: list files. Second tab: cycle matches
set wildmode=longest:full,full
set wildoptions=fuzzy,pum,tagfile
set number
set ttimeout
set ttimeoutlen=100
set display=truncate
set scrolloff=5
set incsearch
" exclude octals from <C-a> / <C-x>
set nrformats-=octal
set noswapfile
set nobackup
set undofile
set textwidth=0
set mouse=a
set ttymouse=xterm2
set termguicolors
set showtabline=2

if has('win32')
	set viminfo='100,<100,s100,:100,n~/vimfiles/viminfo/undo
	set undodir=~/vimfiles
else
	set viminfo='100,<100,s100,:100,n~/.vim/viminfo/undo
	set undodir=~/.vim
endif

set ballooneval 
set balloonevalterm
set balloonexpr=PreviewBalloonExpr()

augroup ballonexpr_grp
	autocmd!
	au User TermdebugStopPost set ballooneval balloonevalterm balloonexpr=PreviewBalloonExpr()
augroup END

" set foldmethod=syntax
" set foldlevel=99
" set autoread
" set autowrite
" set hidden

let c_comment_strings=1
let $PAGER=''
let g:termdebug_config = #{ winbar: 0 }

" C indentation options
" avoid adding leading indentation when a C function declaration starts with
" the return type and name are on separate lines
set cino+=t0
