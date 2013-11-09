"-----------------------------------------------------------
" PLUGINS
"
" CommandT
nnoremap <silent> <Leader>t :CommandTTag<CR>
nnoremap <silent> <C-t> :CommandT<CR>

set wildignore+=*.o,*.obj,.svn,.git,tags
let g:CommandTWildIgnore=&wildignore . ",doc/**,tmp/**,test/tmp/**"



" ----- Minibuf Explorer
"let g:miniBufExplMapWindowNavArrows = 1 " navigate the buffers with Ctrl+{left,up,down,right}.
let g:miniBufExplStatusLineText = " "
"let g:miniBufExplMapWindowNavVim = 1    " navigate the buffers with Ctrl+{j,k,l,m}.
let g:miniBufExplMapWindowNavArrows = 1 " navigate the buffers with Ctrl+{left,up,down,right}.
"let g:miniBufExplMapCTabSwitchBuffs = 1 " use Ctrl+Tab or Shift+Control+Tab to switch to the next buffer.

" let g:miniBufExplModSelTarget = 1
" let g:miniBufExplUseSingleClick = 1

" ----- Tag List Plugin
"let Tlist_Ctags_Cmd="/usr/bin/ctags"
"let Tlist_Use_SingleClick = 1
"let Tlist_Use_Horiz_Window=1
"let Tlist_Use_Right_Window = 1
"let Tlist_Compact_Format = 1
"let Tlist_Exit_OnlyWindow = 1
"let Tlist_GainFocus_On_ToggleOpen = 1
"let Tlist_File_Fold_Auto_Close = 1
" Shorter commands to toggle Taglist display
"nnoremap TT      :TlistToggle<CR>
map      <F5>    :TlistToggle<CR>

" ----- ?
let xml_tag_completion_map = "<C-l>"

" ----- NERDCommenter
let NERDSpaceDelims = 1
