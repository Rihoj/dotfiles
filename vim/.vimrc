filetype plugin indent on
" On pressing tab, insert 2 spaces
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2

function OfCleanUp()
  %s/\[\n\n\!\[Moonsi/[Moonsi/g
  %s/(https:\/\/[^\"]*)\n/\r/g
  %s/\n\n/\r/g
  %s/]\n]/]/g
  %s/^!\[]\n//g
  %s/RB\n,/RB,/g
  %s/Moonsi💜\n,/Moonsi💜,/g
  %s/View message\n//g
  %s/Play Video\n//g
  %s/\(\(RB\|Moonsi💜\), \(Today\|Yesterday\|Apr\|Mar\)\s\(\d\{2} \)\?\d\{1,2}:\d\{2} \(a\|p\)m\)\n\(“\) \n/\1\ \6/g
endfunction
