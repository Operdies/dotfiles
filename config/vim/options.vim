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
set wildmode=list,full
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
set previewpopup=height:10,width:100,border:on
set viminfo='100,<100,s100,:100,n~/.vim/viminfo
set ballooneval 
set balloonevalterm

" set foldmethod=syntax
" set foldlevel=99
" set autoread
" set autowrite
" set hidden

let c_comment_strings=1
let g:asyncrun_open=6
let $PAGER=''
let g:termdebug_config = #{ winbar: 0, }

