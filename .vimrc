set nocompatible

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
nnoremap <silent> <esc> :nohlsearch<cr>:pclose<cr><esc>

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

nmap <space>ff :GitEdit 
nmap <space>cr :!tcc -run %<cr>
nmap <space>fp :OpenProject 
nmap <space>fr :RecentFiles 
" nmap <tab> :wincmd w<cr>
" nmap <esc><tab> :wincmd W<cr>

nnoremap <C-c><C-c> :execute getline('.')<cr>j
set previewpopup=height:10,width:100,border:on

let g:CurrentPreviewSymbol=''
function! s:PreviewSymbol(arg, dir)
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

imap <C-d> <del>
imap <C-b> <Left>
imap <C-f> <Right>

set viminfo='100,<100,s100,:100,n~/.vim/viminfo

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

nnoremap <space>cw <cmd>call Preserve('%s/\s\+$//')<cr>
" open tag in preview window
command! -nargs=+ PreviewSymbol call s:PreviewSymbol(<f-args>)
nnoremap <C-k> <cmd>call Preserve('PreviewSymbol n 1')<cr>
inoremap <C-k> <C-c><cmd>call Preserve('PreviewSymbol i 1')<cr>
nnoremap <C-j> <cmd>call Preserve('PreviewSymbol n 0')<cr>
inoremap <C-j> <C-c><cmd>call Preserve('PreviewSymbol i 0')<cr>

" highlight ExtraWhitespace ctermbg=lightblue guibg=lightblue
" match ExtraWhitespace /\s\+$/
" 
" augroup ExtraWhitespaceGrp
" 	autocmd!
" 	autocmd InsertLeave * highlight ExtraWhitespace ctermbg=lightblue guibg=lightblue
" 	autocmd InsertEnter * highlight clear ExtraWhitespace
" augroup END
" tmap <esc><esc> <C-w>N

nmap <space>p <cmd>.!xclip -o<cr>

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

nnoremap <expr> gc CommentLines()
vnoremap <expr> gc CommentLines()
xnoremap <expr> gc CommentLines()
nnoremap <expr> gcc CommentLines() .. '_'

call plug#begin()
Plug 'skywind3000/asyncrun.vim'
Plug 'tpope/vim-sensible'
call plug#end()

let g:asyncrun_open=10
nmap <C-q> :AsyncRun! make<cr>
