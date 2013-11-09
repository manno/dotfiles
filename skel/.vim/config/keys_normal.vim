"-----------------------------------------------------------
" KEYS
"
" famous paste toggle for xterm vim
set pastetoggle=<F5>

" Folding - need key
"map <kMinus>    zC
"map <kPlus>     zO
"map -           zc
"map +           zo
"map =           gg/{<CR>zM

noremap <C-n>   :bn<CR>
noremap <C-p>   :bp<CR>
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
" OTHER
"
" Map omnifunc to <Ctrl> + Space:
inoremap <Nul> <C-x><C-o>

" debug
map   <F6>      :command

" Use visual in insert mode
" imap <S-Up> <C-O>v
" imap <S-Down> <C-O>v

" load other key config
" map <F12>       :source $HOME/.vim/fkeys_ide.vim<CR>

