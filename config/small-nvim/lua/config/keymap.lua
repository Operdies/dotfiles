local map = vim.keymap.set
local opts = { silent = true, noremap = true }
local function nmap(keys, action)
  map("n", keys, action, opts)
end

-- Insert blank line before/after cursor and restore position
nmap("[<space>", "m'O<esc>`'")
nmap("]<space>", "m'o<esc>`'")
-- restore position after reindenting
nmap("=ip", "m`=ip``")
-- reindent on paste
nmap("p", "p`[v`]=")
nmap("<S-p>", "P`[v`]=")
nmap("<C-s>", ":w<cr>")
nmap("<esc>", "<esc>:nohlsearch<cr>")
nmap("<S-h>", ":bprev<cr>")
nmap("<S-l>", ":bnext<cr>")
nmap("<leader>bd", ":bdelete<cr>")

vim.cmd[[
" buffers
nnoremap [<tab> :tabprev<cr>
nnoremap ]<tab> :tabnext<cr>
nnoremap gb :ls<cr>:b<space>
nnoremap <space>fb :ls<cr>:b<space>
nnoremap <space>ft :tabs<cr>:tabnext<space>
tnoremap <esc>[ <cmd>bprev<cr>
tnoremap <esc>] <cmd>bnext<cr>

" editing
vnoremap <C-j> :m '>+1<cr>gv=gv
vnoremap <C-k> :m '<-2<cr>gv=gv
nnoremap [<space> m'O<esc>`'
nnoremap ]<space> m'o<esc>`'
nnoremap <space>y "+

" search
nnoremap <space>cd <cmd>call RealCd()<cr>
nnoremap <space>gcd <cmd>call CdGitRoot()<cr>
nnoremap <space>qf :cw<cr>
nnoremap <space>cr :!tcc -run %<cr>

nnoremap <expr> <space>ff ":GitEdit " .. input(':e ', '', 'custom,CompleteGitFiles') .. "<cr>"
nnoremap <space>fp :call OpenWizard()<cr>

nnoremap ]q :cnext<cr>
nnoremap [q :cprev<cr>

" insert mode controls
inoremap <C-d> <del>
inoremap <C-b> <Left>
inoremap <C-f> <Right>

" preview tags
nnoremap <silent> <C-k> <cmd>PPopupSymbol <cword><cr>
inoremap <silent> <C-k> <cmd>PPopupSymbol <cword><cr>
nnoremap <silent> <C-j> <cmd>NPopupSymbol <cword><cr>
inoremap <silent> <C-j> <cmd>NPopupSymbol <cword><cr>
nnoremap <silent> <C-h> <cmd>CPopupSymbol<cr>
inoremap <silent> <C-h> <cmd>CPopupSymbol<cr>

" commenting
nnoremap <expr> gc CommentLines()
vnoremap <expr> gc CommentLines()
xnoremap <expr> gc CommentLines()
nnoremap <expr> gcc CommentLines() .. '_'

" window control
nnoremap <C-w>h :call TmuxWinCmd('h')<cr>
nnoremap <C-w>j :call TmuxWinCmd('j')<cr>
nnoremap <C-w>k :call TmuxWinCmd('k')<cr>
nnoremap <C-w>l :call TmuxWinCmd('l')<cr>
nnoremap <C-w><C-h> :call TmuxWinCmd('h')<cr>
nnoremap <C-w><C-j> :call TmuxWinCmd('j')<cr>
nnoremap <C-w><C-k> :call TmuxWinCmd('k')<cr>
nnoremap <C-w><C-l> :call TmuxWinCmd('l')<cr>

" compile
nnoremap <silent> <C-q> :call AsyncRunMegaMaker()<cr>

" debugging
" nnoremap <F1> <cmd>call TermDebugSendCommand("run")<cr>
" nnoremap <F2> <cmd>call TermDebugSendCommand("quit")<cr>:tabclose<cr>
" nnoremap <F3> <cmd>call TermDebugSendCommand("start")<cr>
" nnoremap <F5> <cmd>call TermDebugSendCommand("continue")<cr>
" nnoremap <F9> <cmd>Until<cr>
" nnoremap <F10> <cmd>Over<cr>
" nnoremap <F11> <cmd>Step<cr>
" nnoremap <F12> <cmd>Finish<cr>
" nnoremap <space>db <cmd>Break<cr>
" nnoremap <space>dc <cmd>Clear<cr>
" nnoremap <space>dd <cmd>Until<cr>
" nnoremap <space>dq :GdbDo<space>
" nnoremap <space>dr <cmd>call TermDebugSendCommand("run")<cr>
" nnoremap <space>ds :Debug<space>

" vim stuff
nnoremap <space>so :w<cr>:so %<cr>
nnoremap <C-c><C-c> :execute getline('.')<cr>j
nnoremap <space>p <cmd>.!xclip -o<cr>

" create an undo point before pasting
inoremap <C-r> <C-G>u<C-r>


]]
