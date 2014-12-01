"-----------------------------------------------------------
set ts=8 sw=8 noet smartindent
set foldmethod=syntax
set omnifunc=syntaxcomplete#Complete

"-----------------------------------------------------------
" MACROS 
"
"		// Csharp helper
"       http://vim.sourceforge.net/tips/tip.php?tip_id=589
"
"Create property
imap <C-c><C-p><C-s> <esc>:call CreateProperty("string")<cr>a
imap <C-c><C-p><C-i> <esc>:call CreateProperty("int")<cr>a

function! CreateProperty(type)
    exe "normal bim_\<esc>b\"yywiprivate ".a:type." \<esc>A;\<cr>public ".a:type." \<esc>\"ypb2xea\<cr>{\<esc>oget\<cr>{\<cr>return \<esc>\"ypa;\<cr>}\<cr>set\<cr>{\<cr>\<tab>\<esc>\"yPa = value;\<cr>}\<cr>}\<cr>\<esc>"
    normal 12k2wi
endfunction 		

map !ma       <ESC>:w<CR>:make<CR>
