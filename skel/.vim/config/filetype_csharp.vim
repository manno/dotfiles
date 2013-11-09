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

" CSHARP MAPS
" Protege Schema.java to SemWeb.Schema.cs
"vmap _cj        :s/public static final String/const string/g<CR>:noh<CR>
"vmap _ci        :s/public static final/Entity/g<CR>:noh<CR>
"vmap _ci        :s/Entity .* \(.*\) = m_model..*(\(.*\) );/Entity \1 =\2;/g<CR>:noh<CR>
"vmap _ci        :s/Entity .* \(.*\) = m_model..*(\(.*\), \(.*\) );/Literal \1 = new Literal(\2, null, \3);/g<CR>:noh<CR>
":s@"http://www.owl-ontologies.com/unnamed.owl#\([^"]*\)@URI + "\1@
":%s/^    /\t/g
":%s/Entity /static readonly Entity /
":%s/Literal /static readonly Literal /

"vmap _ci :s@^\(.*\)#\(.*\)$@public const string RDF = "\1#";public static readonly Entity = RDF + "\2";@<CR>:noh<CR>
"vmap _ci :s/\(.*\) = \(.*\) "\(.*\)";/\1 \3 = \2 "\3";/<CR>:noh<CR>
"vmap _ci :s/\(.*\)public.*Entity \(.*\);/\t\1\2,/<CR>:noh<CR>
map !ma       <ESC>:w<CR>:make<CR>
