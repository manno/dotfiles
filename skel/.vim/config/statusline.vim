"-----------------------------------------------------------
" STATUSLINE
" 
set laststatus=2
set ruler
set showcmd                 " show the command in the status line

" Text between "%{" and "%}" is being evaluated
" if version >= 701
"     set statusline=%!MyStatusLine()
" elseif version >= 700
"     set statusline=%<%f%h%m\ %r%y\ %k\ %=%{FuncExists('TagName')}%=\ \[offs=0x%04O\ val=0x%02B\]\ (%03l,%03c)\ %P
" else
"     set statusline=%<%f%h%m\ %r%y\ %k\ %=%=\ \[offs=0x%04O\ val=0x%02B\]\ (%03l,%03c)\ %P
" endif

hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red

set t_Co=256
let g:Powerline_symbols = 'unicode'
