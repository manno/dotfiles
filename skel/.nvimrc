" ----- Colors
set t_Co=256
syntax enable
set synmaxcol=2048 " hugefiles
colorscheme default
hi DiffText       term=reverse cterm=bold ctermbg=9 ctermfg=white

"----- Setup tabs, use spaces instead of tabs
set shiftround
set softtabstop=2
set shiftwidth=2
set tabstop=2
set expandtab
set cf                " Enable error files & error jumping.
set autowrite         " Writes on make/shell commands

"----- speed
set synmaxcol=128
set ttyfast           " u got a fast terminal
set ttyscroll=3
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
"set colorcolumn=120

" jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

"----- Backups & Files
set backup                   " Enable creation of backup file.
set directory=~/.nvim/tmp     " Where temporary files will go.
set backupdir=~/.nvim/tmp/backups " Where backups will go.
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undodir=~/.nvim/tmp/undos
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

augroup NoSimultaneousEdits
    autocmd!
    autocmd  SwapExists  *  :let v:swapchoice = 'o'
augroup END

"----- Search
"
set ignorecase
set smartcase
set incsearch               " show `best match so far' as typed
set hlsearch                " keep highlight until :noh

"----- Encoding
set nodigraph               " you need digraphs for uumlauts
if has("multi_byte")        " vim tip 245
     set encoding=utf-8     " how vim shall represent characters internally
     set fileencodings=utf-8,iso-8859-15,ucs-bom    " heuristic
     set virtualedit=block " fix problem with yank in utf8
else
     echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte"
endif

"----- Gui Vim
if has("gui_running")
    set guifont=Monospace\ 9
    set guioptions-=m        " remove menu bar
    set guioptions-=T        " remove tool bar
    set guioptions-=r
    set guioptions-=L
endif

"----- Diffmode
if &diff
    syntax off
    " FIXME wrapping ?
    "set wrap
    set diffopt+=iwhite
endif

" ----- Statusline
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

set thesaurus+=~/.vim/spell/thesaurus.txt

" ----- Keys / Mappings / Commands
"
" famous paste toggle for xterm vim
set pastetoggle=<F5>

noremap <C-n>   :bn<CR>
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

" use ; for ex commands
"nnoremap ; :

" quit all buffers - qa/wa
command! Q      :quitall

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

" ----- Converter Mappings
"
" convert to html
map  _th     :source $VIMRUNTIME/syntax/2html.vim
" convert to colored tex, use TMiniBufExplorer first
map  _tt     :source $VIMRUNTIME/syntax/2tex.vim
" convert to colored ansi
vmap _ta     :TOansi

" SEARCH
map \g     :Ggrep <C-R><C-W><CR>

" ----- Mousewheel in Xterm
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

" ----- Vundle
"
" apt-get install cmake python-dev
set rtp+=~/.nvim/bundle/vundle
call vundle#rc("~/.nvim/bundle")

Bundle 'gmarik/vundle'

" nerd
Bundle 'The-NERD-Commenter'

" grep
"Bundle 'vim-scripts/grep.vim'
Bundle 'manno/grep'

" search with ag?
"Bundle 'rking/ag.vim'

" Status line
Bundle 'vim-airline'

Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimproc.vim'

" tab completion
" Bundle 'ervandew/supertab'

" you complete me - needs vim 7.3.584
" https://github.com/Valloric/YouCompleteMe
"Bundle 'Valloric/YouCompleteMe'

" TODO neocomplete instead?
"Bundle 'Shougo/neocomplete.vim'
Bundle 'Shougo/neocomplcache.vim'

" syntax errors
Bundle 'scrooloose/syntastic'

" Colorschemes
"Bundle 'jonathanfilip/vim-lucius'
"Bundle 'tomasr/molokai'
"Bundle 'noahfrederick/vim-hemisu'

" ctags support
Bundle 'vim-tags'

" Tmux integration
Bundle 'edkolev/tmuxline.vim'

" Format SQL
Bundle 'vim-scripts/SQLUtilities'
Bundle 'vim-scripts/Align'

" surround - yse' veS'
Bundle 'tpope/vim-surround.git'

" vim ruby
" gem install gem-ctags
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-rake'

" file
Bundle 'manno/file-line'

" Gvim Related
Bundle 'airblade/vim-rooter'

" syntax
Bundle 'vim-polyglot'

" Git
Bundle 'fugitive.vim'

" latexsuite = vim-latex

" ----- Plugin Configurations
"
" CommandT
"nnoremap <silent> <Leader>t :CommandTTag<CR>
"nnoremap <silent> <C-t> :CommandT<CR>
" since we bound ctrl-t to commandt / unite
let @t = ":pop"
set wildignore+=*.o,*.obj,.svn,.git,tags
"let g:CommandTWildIgnore=&wildignore . ",doc/**,tmp/**,test/tmp/**"

" Unite
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
call unite#custom#source('file_rec,file_rec/async', 'max_candidates', 1000)
call unite#custom#source('file_rec,file_rec/git', 'max_candidates', 0)
call unite#custom_source('file_rec,file_rec/async,file,grep',
      \ 'ignore_pattern', join([
      \ 'tmp/',
      \ '\.git/',
      \ ], '\|'))
"nnoremap <C-t> :<C-u>Unite -start-insert file_rec/async:!<CR>
nnoremap <C-t> :<C-u>Unite -no-split -start-insert file_rec/git:--cached:--exclude-standard<CR>
nnoremap <Leader>b :<C-u>Unite -no-split -start-insert buffer<CR>

autocmd FileType unite call s:unite_settings()

function! s:unite_settings()
    let b:SuperTabDisabled=1
    nmap <buffer> <ESC> <Plug>(unite_exit)
    nmap <buffer> <C-c> <Plug>(unite_exit)
endfunction

" Syntastic /  Rubocop 
"let g:syntastic_quiet_messages = {'level': 'warnings'}
"let g:syntastic_ruby_checkers = ['mri', 'rubocop']
let g:syntastic_ruby_checkers = ['rubocop', 'mri']
let g:syntastic_ruby_rubocop_args = "-D"

" YCM
"let g:ycm_register_as_syntastic_checker = 0

" Neocomplete
"let g:neocomplete#enable_at_startup = 1
let g:neocomplcache_enable_at_startup = 1 

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

" ----- Colorschemes
"colorscheme lucius
"hi Normal ctermbg=White

" ----- ?
let xml_tag_completion_map = "<C-l>"

" ----- NERDCommenter
let NERDSpaceDelims = 1
