packadd! matchit
packadd! termdebug

call plug#begin()
Plug 'skywind3000/asyncrun.vim'
Plug 'tpope/vim-sensible'
Plug 'voldikss/vim-floaterm'
call plug#end()

filetype plugin indent on
syntax on

colorscheme catppuccin_mocha

let g:floaterm_wintype="float"
let g:floaterm_height=0.9
let g:floaterm_width=0.9

if has('win32')
	set shell=powershell\ /NoLogo
	set shellcmdflag=-command
	set shellquote=\"
	set shellxquote=
endif

if has('gui')
	nnoremap <M-\> <cmd>FloatermToggle<cr>
	tnoremap <M-\> <cmd>FloatermToggle<cr>
	tnoremap <M-]> <cmd>FloatermNext<cr>
	tnoremap <M-[> <cmd>FloatermPrev<cr>
	tnoremap <M-=> <cmd>FloatermNew<cr>
	tnoremap <M-q> <cmd>FloatermKill<cr>
else
	nnoremap <esc>\ <cmd>FloatermToggle<cr>
	tnoremap <esc>\ <cmd>FloatermToggle<cr>
	tnoremap <esc>] <cmd>FloatermNext<cr>
	tnoremap <esc>[ <cmd>FloatermPrev<cr>
	tnoremap <esc>= <cmd>FloatermNew<cr>
	tnoremap <esc>q <cmd>FloatermKill<cr>
endif

nnoremap <space>gg <cmd>FloatermNew --name=lazygit --autoclose=2 lazygit<cr>

