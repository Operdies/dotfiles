set nocompatible
set shiftwidth=2
set tabstop=2
set expandtab
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

let g:termdebug_config = #{ winbar: 0 }

" C indentation options
" avoid adding leading indentation when a C function declaration starts with
" the return type and name are on separate lines
set cino+=t0
