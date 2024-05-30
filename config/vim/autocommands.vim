autocmd BufReadPost *
			\ let line = line("'\"")
			\ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
			\      && index(['xxd', 'gitrebase'], &filetype) == -1
			\ |   execute "normal! g`\""
			\ | endif

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

augroup vimtagfile
	autocmd!
	autocmd FileType vim let &l:tags = &g:tags .. ',' .. '/usr/share/vim/vim91/doc/tags'
augroup END

function! s:AsyncRunAlert()
	let what = "asyncrun finished"
	call Toast(what, 5000)
endfunction

augroup asyncrun
	autocmd!
	autocmd User AsyncRunStop let __window=win_getid(winnr()) | execute "cwindow" | call win_gotoid(__window) | call s:AsyncRunAlert()
augroup END

augroup additional_filetypes
	autocmd!
	autocmd BufEnter *.csproj set filetype=xml
	autocmd BufEnter *.props set filetype=xml
augroup END
