for f in range(1, 12)
	let key = 'F' .. f
	execute 'nnoremap <' .. key  .. '> :echo "<' .. key .. '>"<cr>'
	execute 'noremap <S-' .. key  .. '> :echo "<S-' .. key .. '>"<cr>'
	execute 'nnoremap <C-' .. key  .. '> :echo "<C-' .. key .. '>"<cr>'
endfor

