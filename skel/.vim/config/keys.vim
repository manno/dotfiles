"-----------------------------------------------------------
" KEYS
"
" famous paste toggle for xterm vim
set pastetoggle=<F5>

noremap <C-n>   :bn<CR>
"nnoremap <silent> <C-n> :if &buftype ==# 'quickfix'<Bar>bn<Bar>endif<CR>

noremap <C-p>   :bp<CR>

augroup QFix
    autocmd!
    autocmd FileType qf setlocal nobuflisted
augroup END


" navigate windows
noremap <C-Down>  <C-W>j
noremap <C-Up>    <C-W>k
noremap <C-Left>  <C-W>h
noremap <C-Right> <C-W>l
"-----------------------------------------------------------
" COMMANDS

" use ; for ex commands
"nnoremap ; :

" quit all buffers - qa/wa
command! Q      :quitall

"noremap <C-Del> :bw
"-----------------------------------------------------------
" OTHER
"
" Map omnifunc to <Ctrl> + Space:
inoremap <Nul> <C-x><C-o>

" debug
map   <F6>      :command

" make
map !ma       <ESC>:w<CR>:make<CR>

" exchange two letters, like shell <ctrl-t>
let @t = "xhPll"

" forgot to open as root?
command! Wsudo  :w !sudo tee > /dev/null %

" format json 
com! -range FormatJSON <line1>,<line2>!python -m json.tool

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
map \g     :Ggrep <C-R><C-W><CR>

"-----------------------------------------------------------
" MOUSEWHEEL IN XTERM
"
map <M-Esc>[62~ <MouseDown>
map! <M-Esc>[62~ <MouseDown>
map <M-Esc>[63~ <MouseUp>
map! <M-Esc>[63~ <MouseUp>
map <M-Esc>[64~ <S-MouseDown>
map! <M-Esc>[64~ <S-MouseDown>
map <M-Esc>[65~ <S-MouseUp>
map! <M-Esc>[65~ <S-MouseUp>

"-----------------------------------------------------------
" Fn KEYS
"
" use shift fkeys
" <S-Fn> problems:
"   * some don't work
"   * some may trigger on other keys

"" keymap error (F12=[24~) ???
" set     <F12>=<Char-0xffc9>
set     <F12>=<Char-96>
set     <S-F2>=[24~   
set     <S-F3>=[25~
" UNDO set     <S-F4>=[26~
" set     <S-F5>=[28~
" LOGO set     <S-F6>=[29~
" set     <S-F7>=[31~

