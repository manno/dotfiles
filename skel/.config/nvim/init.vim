" ----- Colors
"set t_Co=256
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
syntax enable
colorscheme default
"hi DiffText       term=reverse cterm=bold ctermbg=9 ctermfg=white
"hi DiffAdd    term=reverse cterm=bold ctermbg=green ctermfg=white
"hi DiffChange term=reverse cterm=bold ctermbg=cyan  ctermfg=black
"hi DiffText   term=reverse cterm=bold ctermbg=gray  ctermfg=black
"hi DiffDelete term=reverse cterm=bold ctermbg=red   ctermfg=black
"hi DiffAdd        term=bold ctermbg=81
"hi DiffChange     term=bold ctermbg=225
"hi DiffDelete     term=bold ctermfg=12 ctermbg=159

set mouse=ivh

"----- Setup tabs, use spaces instead of tabs
set shiftround
set softtabstop=2
set shiftwidth=2
set tabstop=2
set expandtab
set cf                " Enable error files & error jumping.
set autowrite         " Writes on make/shell commands

"----- speed
set synmaxcol=256
set lazyredraw        " to avoid scrolling problems


"----- Setup document specifics
set autoindent
filetype on                       " Enable filetype detection
filetype indent on                " Enable filetype-specific indenting
filetype plugin on                " Enable filetype-specific plugins
set hidden                        " Allow hidden buffers
set noinsertmode                  " don't don't out in insert mode
set backspace=indent,eol,start    " allow us to backspace before an insert
set wildmenu
set wildignore+=*.o,*.obj,.svn,.git,tags
"set colorcolumn=120

" jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

"----- Backups & Files
set backup                   " Enable creation of backup file.
set backupdir=~/.local/share/nvim/backup " Where backups will go.
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

augroup NoSimultaneousEdits
    autocmd!
    autocmd  SwapExists  *  :let v:swapchoice = 'o'
augroup END

"----- Search
set ignorecase
set smartcase
set incsearch               " show `best match so far' as typed
set hlsearch                " keep highlight until :noh

"----- Encoding
set nodigraph               " you need digraphs for uumlauts
if has("multi_byte")        " vim tip 245
     set fileencodings=utf-8,iso-8859-15,ucs-bom    " heuristic
     set virtualedit=block " fix problem with yank in utf8
else
     echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte"
endif

"----- Diffmode
if &diff
    syntax off
    " FIXME wrapping ?
    "set wrap
    set diffopt+=iwhite
endif

"----- Statusline
set laststatus=2
set ruler
set showcmd                 " show the command in the status line

"autocmd FileType c nnoremap <buffer> <silent> <C-]> :YcmCompleter GoTo<cr>

" ----- Spelling
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

set thesaurus+=~/.config/nvim/spell/thesaurus.txt

" ----- Keys / Mappings / Commands
"
" famous paste toggle for xterm vim
set pastetoggle=<F5>

" buffer next/prev
nnoremap <C-n>   :bn<CR>
nnoremap <C-p>   :bp<CR>

" navigate windows / splits
nnoremap <C-Down>  <C-W>j
nnoremap <C-Up>    <C-W>k
nnoremap <C-Left>  <C-W>h
nnoremap <C-Right> <C-W>l

" quit all buffers - qa/wa
command! Q      :quitall

" close current buffer
map <M-w>        <ESC>:bw<CR>

" debug
map   <F6>      :command

" make
map !ma       <ESC>:w<CR>:make<CR>

" since ctrl-t is bound to commandt / unite / fzf
let @t = ":pop"

" SEARCH
map \g     :Ggrep <C-R><C-W><CR>

" ----- Mousewheel in Xterm
"
map <M-Esc>[62~ <MouseDown>
map! <M-Esc>[62~ <MouseDown>
map <M-Esc>[63~ <MouseUp>
map! <M-Esc>[63~ <MouseUp>
map <M-Esc>[64~ <S-MouseDown>
map! <M-Esc>[64~ <S-MouseDown>
map <M-Esc>[65~ <S-MouseUp>
map! <M-Esc>[65~ <S-MouseUp>

" ----- Fn Keys
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

" forgot to open as root?
command! Wsudo  :w !sudo tee > /dev/null %

command! Tidy :%!/opt/tidy-html5/bin/tidy -w -i -q -f /dev/null

" format json
com! -range FormatJSON <line1>,<line2>!python -m json.tool

" ----- Converter Mappings
"
" convert to html
map  _th     :source $VIMRUNTIME/syntax/2html.vim
" convert to colored tex, use TMiniBufExplorer first
map  _tt     :source $VIMRUNTIME/syntax/2tex.vim
" convert to colored ansi
vmap _ta     :TOansi

" ----- Plug
"auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif
call plug#begin('~/.config/nvim/plugged')

" nerd
Plug 'The-NERD-Commenter'

" grep
"Plug 'vim-scripts/grep.vim'
Plug 'manno/grep'

" search with ag?
"Plug 'rking/ag.vim'

" status line
Plug 'vim-airline'

" open files
"Plug 'Shougo/unite.vim'
"Plug 'Shougo/vimproc.vim', { 'do': 'make' }
"Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" you complete me - needs vim 7.3.584
" https://github.com/Valloric/YouCompleteMe
"Plug 'Valloric/YouCompleteMe', { 'do': './install.sh' }

" TODO neocomplete instead?
"Plug 'Shougo/neocomplete.vim'
"Plug 'Shougo/neocomplcache.vim'
"Plug 'Shougo/deoplete.nvim'
function! DoRemote(arg)
  UpdateRemotePlugins
endfunction
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }

"Plug 'osyo-manga/vim-monster'
"let g:monster#completion#rcodetools#backend = "async_rct_complete"
"let g:neocomplete#force_omni_input_patterns = { 'ruby' : '[^. *\t]\.\|\h\w*::', }

" syntax errors
"Plug 'scrooloose/syntastic'
Plug 'benekastah/neomake'

" Colorschemes
Plug 'jonathanfilip/vim-lucius'
Plug 'tomasr/molokai'
Plug 'noahfrederick/vim-hemisu'
Plug 'endel/vim-github-colorscheme'
Plug 'chriskempson/vim-tomorrow-theme'

" ctags support
Plug 'szw/vim-tags'
Plug 'majutsushi/tagbar'

" tmux integration
Plug 'edkolev/tmuxline.vim'

" format SQL
Plug 'vim-scripts/SQLUtilities'
Plug 'vim-scripts/Align'

" surround - yse' veS'
Plug 'tpope/vim-surround'

" vim ruby
" gem install gem-ctags
Plug 'tpope/vim-bundler', { 'for': 'ruby' }
Plug 'tpope/vim-rake', { 'for': 'ruby' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'janko-m/vim-test'

" open files at line
Plug 'manno/file-line'

" gvim related - change project root
Plug 'airblade/vim-rooter'

" polyglot bundles csv.vim and an old version too
" Instead install separately https://github.com/sheerun/vim-polyglot
" Plug 'vim-polyglot'
Plug 'stephpy/vim-yaml', { 'for': 'yaml' }
Plug 'tpope/vim-git', { 'for': 'git' }
Plug 'tpope/vim-haml', { 'for': 'haml' }
Plug 'tpope/vim-markdown', { 'for': 'markdown' }
Plug 'sheerun/yajs.vim', { 'for': 'javascript' }
Plug 'honza/dockerfile.vim', { 'for': 'docker' }
Plug 'JulesWang/css.vim', { 'for': 'css' }
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'mitsuhiko/vim-python-combined', { 'for': 'python' }
Plug 'vim-scripts/R.vim', { 'for': 'r' }

" git
Plug 'fugitive.vim'

" latexsuite = vim-latex
Plug 'vim-latex/vim-latex', { 'for': 'tex' }

call plug#end()

" ----- Plugin Configurations
"

" CommandT
"nnoremap <silent> <Leader>t :CommandTTag<CR>
"nnoremap <silent> <C-t> :CommandT<CR>
"let g:CommandTWildIgnore=&wildignore . ",doc/**,tmp/**,test/tmp/**"

" " Unite
" call unite#filters#matcher_default#use(['matcher_fuzzy'])
" call unite#filters#sorter_default#use(['sorter_rank'])
" call unite#custom#source('file_rec,file_rec/async', 'max_candidates', 1000)
" call unite#custom#source('file_rec,file_rec/git', 'max_candidates', 0)
" call unite#custom_source('file_rec,file_rec/async,file,grep',
"       \ 'ignore_pattern', join([
"       \ 'tmp/',
"       \ '\.git/',
"       \ ], '\|'))
" nnoremap <C-f> :<C-u>Unite -start-insert file_rec/async:!<CR>
" nnoremap <C-t> :<C-u>Unite -no-split -start-insert file_rec/git:--cached:--exclude-standard<CR>
" nnoremap <Leader>b :<C-u>Unite -no-split -start-insert buffer<CR>

" autocmd FileType unite call s:unite_settings()

" function! s:unite_settings()
"     let b:SuperTabDisabled=1
"     nmap <buffer> <ESC> <Plug>(unite_exit)
"     nmap <buffer> <C-c> <Plug>(unite_exit)
" endfunction

" CtrlP
"let g:ctrlp_map = '<c-t>'
"let g:ctrlp_user_command = 'git ls-files %s'
"nnoremap <Leader>b :CtrlPBufTag<cr>

" Syntastic /  Rubocop 
"let g:syntastic_quiet_messages = {'level': 'warnings'}
"let g:syntastic_ruby_checkers = ['rubocop', 'mri']
"let g:syntastic_ruby_rubocop_args = "-D"

" YCM
"let g:ycm_register_as_syntastic_checker = 0

" vim-tags
"let g:vim_tags_ctags_binary = "/opt/universal-ctags/bin/ctags"
"let g:vim_tags_project_tags_command = "{CTAGS} --recurse {OPTIONS} {DIRECTORY} 2>/dev/null"
"let g:vim_tags_gems_tags_command = "{CTAGS} --recurse {OPTIONS} `bundle show --paths` 2>/dev/null"

" fzf
map <C-t> :GitFiles<CR>
map <M-b> :Buffers<CR>

" vim-test
nmap <F3> :TestFile<CR>
let test#strategy = "neovim"

" tagbar
nmap <F5> :TagbarToggle<CR>

" Neocomplete
"let g:neocomplete#enable_at_startup = 1
"let g:neocomplcache_enable_at_startup = 1 
let g:deoplete#enable_at_startup = 1

" fugitive git grep
autocmd QuickFixCmdPost *grep* cwindow

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='sol'
let g:airline#extensions#branch#enabled = 0

" if !exists('g:airline_symbols')
"     let g:airline_symbols = {}
" endif
" let g:airline_symbols.space = "\ua0"

" don't show quickfix in buffer list
augroup QFix
    autocmd!
    autocmd FileType qf setlocal nobuflisted
augroup END


" Vim Rooter
let g:rooter_patterns = [ 'package.json', 'README.md', 'Rakefile', '.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/' ]

" ----- Colorschemes
"colorscheme lucius
"hi Normal ctermbg=White
colorscheme github

" ----- ?
let xml_tag_completion_map = "<C-l>"

" ----- NERDCommenter
let NERDSpaceDelims = 1

" ----- Terminal
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
