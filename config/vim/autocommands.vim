autocmd BufReadPost *
			\ let line = line("'\"")
			\ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
			\      && index(['xxd', 'gitrebase'], &filetype) == -1
			\ |   execute "normal! g`\""
			\ | endif


augroup bufferlinegrp
	autocmd!
	autocmd BufEnter,BufNew,InsertLeave,CursorHold * call UpdateBufferline(expand("<abuf>"), 0, 0)
	autocmd BufDelete * call UpdateBufferline(expand("<abuf>"), 1, 0)
	autocmd BufWrite * call UpdateBufferline(expand("<abuf>"), 0, 1)
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

augroup asyncrun
	autocmd!
	autocmd User AsyncRunStop execute "cwindow"
augroup END

augroup termdebug
	autocmd!
	autocmd User TermdebugStartPost wincmd p | wincmd H
augroup END
