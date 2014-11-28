"-----------------------------------------------------------
" SPELLING
"
" Rechtschreibung & Word Processing: move cursor in editor lines, not text lines
" change to utf8 umlaut compatible mode with digraphs
" http://vim.wikia.com/wiki/VimTip38
function WordProcessor(enable)
  if a:enable
    echo "WordProcessor Mode: enabled"
    imap <Up> <C-O>gk
    imap <Down> <C-O>gj
"    set digraph
  else
    echo "WordProcessor Mode: disabled"
    silent! iunmap <Up>
    silent! iunmap <Down>
"   set nodigraph
  endif
endfunction

map <F8>        :setlocal spell spelllang=de_20,de,en<CR>:call WordProcessor(1)<CR>
map <s-F8>      :setlocal spell spelllang=en<CR>:call WordProcessor(1)<CR>
map <esc><F8>   :setlocal nospell<CR>:call WordProcessor(0)<CR>

" FIXME Spell check mode (?)
map <Up> gk
map <Down> gj

set thesaurus+=~/.vim/spell/thesaurus.txt
