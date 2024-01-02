" close all folds
nnoremap zC :setlocal foldlevel=0<cr>
" open all folds
nnoremap zO :setlocal foldlevel=99<cr>

nnoremap <C-s> :w<cr>
nnoremap H :bprev!<cr>
nnoremap L :bnext!<cr>
nnoremap [<tab> :tabprev<cr>
nnoremap ]<tab> :tabnext<cr>
nnoremap <space>bd :bdelete<cr>
nnoremap <space>gg :silent !lazygit<cr><C-l>
nnoremap K :Man <cword><cr>
nnoremap [<space> m'O<esc>`'
nnoremap ]<space> m'o<esc>`'
nnoremap <space>y "+
nnoremap gp `[v`]
vnoremap < <gv
vnoremap > >gv
" nnoremap <C-j> :m .+1<cr>==
" nnoremap <C-k> :m .-2<cr>==
vnoremap <C-j> :m '>+1<cr>gv=gv
vnoremap <C-k> :m '<-2<cr>gv=gv

" create an undo point before pasting
inoremap <C-r> <C-G>u<C-r>

nnoremap <space>o :e %:p:h<cr>
nnoremap <space>cd <cmd>call RealCd()<cr>
nnoremap <space>fw /\<

nnoremap ]q :cnext<cr>
nnoremap [q :cprev<cr>

nnoremap [g :lprev<cr>
nnoremap ]g :lnext<cr>

" indent text after pasting
nnoremap p p`[v`]=
nnoremap P P`[v`]=

nnoremap <space>fg :silent DoGrep<cr>
nnoremap <space>fG :silent DoFuzzyGrep<cr>
nnoremap <space>qf :cw<cr>
nnoremap <silent> <esc> :nohlsearch<cr>:pclose<cr><esc>

nnoremap gb :ls<cr>:b<space>
nnoremap <space>fb :ls<cr>:b<space>
nnoremap <space>ft :tabs<cr>:tabnext<space>

nnoremap <space>so :w<cr>:so %<cr>

nnoremap <space>ff :GitEdit 
nnoremap <space>cr :!tcc -run %<cr>
nnoremap <space>fp :OpenProject 
nnoremap <space>fr :RecentFiles 
" nnoremap <tab> :wincmd w<cr>
" nnoremap <esc><tab> :wincmd W<cr>

nnoremap <C-c><C-c> :execute getline('.')<cr>j

inoremap <C-d> <del>
inoremap <C-b> <Left>
inoremap <C-f> <Right>

nnoremap <space>cw <cmd>call Preserve('%s/\s\+$//')<cr>
nnoremap <C-k> <cmd>call Preserve('PreviewSymbol n 1')<cr>
inoremap <C-k> <C-c><cmd>call Preserve('PreviewSymbol i 1')<cr>
nnoremap <C-j> <cmd>call Preserve('PreviewSymbol n 0')<cr>
inoremap <C-j> <C-c><cmd>call Preserve('PreviewSymbol i 0')<cr>

tnoremap <esc>[ <cmd>bprev<cr>
tnoremap <esc>] <cmd>bnext<cr>

nnoremap <space>p <cmd>.!xclip -o<cr>

nnoremap <expr> gc CommentLines()
vnoremap <expr> gc CommentLines()
xnoremap <expr> gc CommentLines()
nnoremap <expr> gcc CommentLines() .. '_'

nnoremap <C-q> :call AsyncRunMegaMaker()<cr>

nnoremap <C-w>h :call TmuxWinCmd('h')<cr>
nnoremap <C-w>j :call TmuxWinCmd('j')<cr>
nnoremap <C-w>k :call TmuxWinCmd('k')<cr>
nnoremap <C-w>l :call TmuxWinCmd('l')<cr>
nnoremap <C-w><C-h> :call TmuxWinCmd('h')<cr>
nnoremap <C-w><C-j> :call TmuxWinCmd('j')<cr>
nnoremap <C-w><C-k> :call TmuxWinCmd('k')<cr>
nnoremap <C-w><C-l> :call TmuxWinCmd('l')<cr>

nnoremap <space>bD <cmd>call CleanBufferList()<cr>

nnoremap <F1> <cmd>call TermDebugSendCommand("run")<cr>
nnoremap <F2> <cmd>call TermDebugSendCommand("quit")<cr>
nnoremap <F3> <cmd>call TermDebugSendCommand("start")<cr>
nnoremap <F5> <cmd>call TermDebugSendCommand("continue")<cr>
nnoremap <F9> <cmd>Until<cr>
nnoremap <F10> <cmd>Over<cr>
nnoremap <F11> <cmd>Step<cr>
nnoremap <F12> <cmd>Finish<cr>

nnoremap <space>db <cmd>Break<cr>
nnoremap <space>dc <cmd>Clear<cr>
nnoremap <space>dd <cmd>Until<cr>
nnoremap <space>dq <cmd>call TermDebugSendCommand("quit")<cr>
nnoremap <space>dr <cmd>call TermDebugSendCommand("run")<cr>
nnoremap <space>ds <cmd>Stop<cr>
