"-----------------------------------------------------------
" PLUGINS
"
" CommandT
nnoremap <silent> <Leader>t :CommandTTag<CR>
nnoremap <silent> <C-t> :CommandT<CR>

set wildignore+=*.o,*.obj,.svn,.git,tags
let g:CommandTWildIgnore=&wildignore . ",doc/**,tmp/**,test/tmp/**"

" Syntastic /  Rubocop 
let g:syntastic_quiet_messages = {'level': 'warnings'}
let g:syntastic_ruby_checkers = ['mri', 'rubocop']

" YCM
let g:ycm_register_as_syntastic_checker = 0

" fugitive git grep
autocmd QuickFixCmdPost *grep* cwindow

" airline
let g:airline#extensions#tabline#enabled = 1

" tango
colorscheme tango

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
