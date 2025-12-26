filetype plugin indent on
" On pressing tab, insert 2 spaces
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2

" :W writes the file, creating parent dirs if needed
command! -bar -bang W call s:mkdir_and_write(<bang>0)

function! s:mkdir_and_write(force)
	let l:dir = expand('%:p:h')
	if l:dir !=# '' && !isdirectory(l:dir)
		call mkdir(l:dir, 'p')
	endif
	execute 'write' . (a:force ? '!' : '')
endfunction

nnoremap <leader>w :W<CR>