"-----------------------------------------------------------
" PLUGINS
"
" ----- Minibuf Explorer
"let g:miniBufExplMapWindowNavVim = 1    " navigate the buffers with Ctrl+{j,k,l,m}.
let g:miniBufExplMapWindowNavArrows = 1 " navigate the buffers with Ctrl+{left,up,down,right}.
"let g:miniBufExplMapCTabSwitchBuffs = 1 " use Ctrl+Tab or Shift+Control+Tab to switch to the next buffer.

" let g:miniBufExplModSelTarget = 1
" let g:miniBufExplUseSingleClick = 1

" ----- Fuzzy Finder Plugin
" http://github.com/jamis/fuzzy_file_finder/tree/master
map <C-t> :FuzzyFinderTextMate<CR>

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
"map      <F4>    :TlistToggle<CR>

""-- " ----- Tag Explorer Plugin
""-- let TE_Ctags_Path  = '/usr/bin/ctags'
""-- let TE_Exclude_File_Pattern ='.*\.o$\|.*\.obj$\|.*\.bak$' . '\|.*\.swp$\|core\|tags' . '\|.*\.pyc$\'
""-- let TE_Exclude_Dir_Pattern = '\.svn' 
""-- 
""-- " ----- Cscope Plugin
""-- if has("cscope")
""--         "set csprg=/usr/local/bin/cscope
""--         set csto=0
""--         set cst
""--         set nocsverb
""--         " add any database in current directory with full path 
""--         if filereadable("cscope.out")
""--             let csfile=printf("%s/cscope.out",getcwd())
""--             cs add csfile
""--         " else add database pointed to by environment
""--         elseif $CSCOPE_DB != ""
""--             cs add $CSCOPE_DB
""--         endif
""--         set csverb
""-- endif

let xml_tag_completion_map = "<C-l>"

let NERDSpaceDelims = 1
