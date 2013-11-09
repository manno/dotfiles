"-----------------------------------------------------------
" CONVERTER MAPS
"
" convert to html
map  _th     :source $VIMRUNTIME/syntax/2html.vim
" convert to colored tex, use TMiniBufExplorer first
map  _tt     :source $VIMRUNTIME/syntax/2tex.vim
" convert to colored ansi
vmap _ta     :TOansi

" SEARCH
map ,g     :Bgrep /<C-R><C-W>/

" COMMENT MAPS
" use NERD_commenter (,c<SPACE> ,cl ,cb ,cs)
" un/comment block
"vmap    _cb     :s/^/# /<CR>:noh<CR>
"vmap    _ub     :s/^# //<CR>:noh<CR>
" un/comment
"vmap    _c      :s/\(\S\)/#\1/<CR>:noh<CR>
"vmap    _u      :s/#//<CR>:noh<CR>

" OTHER MAPS
"@t     exchange two letters, like shell <ctrl-t>
let @t = "xhPll"

" COMMANDS
" quit all buffers
command! Q      :quitall
" dupe it so :W does nothing
command! Wq     :call s:writequitall()
command! WQ     :call s:writequitall()

" forgot to open as root?
"command! Wsudo  :w !sudo tee %
command! Wsudo  :w !sudo tee > /dev/null %

" SPELLCHECKING
" enable:
" setlocal spell spelllang=en_us
"
