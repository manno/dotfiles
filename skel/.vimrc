" ----- Colors
set t_Co=256
syntax enable
colorscheme default
"hi DiffAdd    term=reverse cterm=bold ctermbg=green ctermfg=white
"hi DiffChange term=reverse cterm=bold ctermbg=cyan  ctermfg=black
"hi DiffText   term=reverse cterm=bold ctermbg=gray  ctermfg=black
"hi DiffDelete term=reverse cterm=bold ctermbg=red   ctermfg=black
"hi DiffAdd        term=bold ctermbg=81
"hi DiffChange     term=bold ctermbg=225
"hi DiffDelete     term=bold ctermfg=12 ctermbg=159
hi DiffText       term=reverse cterm=bold ctermbg=9 ctermfg=white

"colorscheme mayansmoke
"colorscheme hemisu

set nocompatible      " We're running Vim, not Vi!

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
"set colorcolumn=120

" jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

"----- Backups & Files
set backup                   " Enable creation of backup file.
set directory=~/.vim/tmp     " Where temporary files will go.
set backupdir=~/.vim/tmp/backups " Where backups will go.
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undodir=~/.vim/tmp/undos
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

augroup NoSimultaneousEdits
    autocmd!
    autocmd  SwapExists  *  :let v:swapchoice = 'o'
augroup END

"----- Mouse mode
if has("mouse")
    set mouse=vihr          " mouse in insert/visual/help mode only
endif

"----- Search
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
    "syntax off
    " FIXME wrapping ?
    "set wrap
    set diffopt+=iwhite
endif

"----- Statusline
set laststatus=2
set ruler
set showcmd                 " show the command in the status line

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

" FIXME Spell check mode (?)
"map <Up> gk
"map <Down> gj

set thesaurus+=~/.vim/spell/thesaurus.txt

" ----- Keys / Mappings / Commands
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

" ----- Plug
call plug#begin('~/.vim/plugged')

" nerd
Plug 'The-NERD-Commenter'

" grep
"Plug 'vim-scripts/grep.vim'
Plug 'manno/grep'

" search with ag?
Plug 'rking/ag.vim'

" status line
Plug 'vim-airline'

" open files
Plug 'git://git.wincent.com/command-t.git', { 'do': 'rvm use system; ruby extconf.rb && make clean && make'}

" open files
"Plug 'Shougo/unite.vim'
"Plug 'Shougo/vimproc.vim', { 'do': 'make' }

" you complete me - needs vim 7.3.584
" https://github.com/Valloric/YouCompleteMe
"Plug 'Valloric/YouCompleteMe', { 'do': './install.sh' }

" TODO neocomplete instead?
"Plug 'Shougo/neocomplete.vim'
"Plug 'Shougo/neocomplcache.vim'

" syntax errors
Plug 'scrooloose/syntastic'

" Colorschemes
"Plug 'jonathanfilip/vim-lucius'
"Plug 'tomasr/molokai'
"Plug 'noahfrederick/vim-hemisu'
Plug 'endel/vim-github-colorscheme'

" ctags support
Plug 'vim-tags'

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
"Plug 'tpope/vim-rails', { 'for': 'ruby' }

" file
Plug 'manno/file-line'

" gvim Related
Plug 'airblade/vim-rooter'

" syntax
Plug 'vim-polyglot'

" git
Plug 'fugitive.vim'

" latexsuite = vim-latex

call plug#end()

" ----- Plugin Configurations
"
" CommandT
nnoremap <silent> <Leader>t :CommandTTag<CR>
nnoremap <silent> <C-t> :CommandT<CR>

" since we bound ctrl-t to commandt
let @t = ":pop"

" CtrlP
"let g:ctrlp_map = '<c-t>'

set wildignore+=*.o,*.obj,.svn,.git,tags
let g:CommandTWildIgnore=&wildignore . ",doc/**,tmp/**,test/tmp/**"

" Syntastic /  Rubocop
"let g:syntastic_quiet_messages = {'level': 'warnings'}
"let g:syntastic_ruby_checkers = ['mri', 'rubocop']
let g:syntastic_ruby_checkers = ['rubocop', 'mri']
let g:syntastic_ruby_rubocop_args = "-D"

" YCM
let g:ycm_register_as_syntastic_checker = 0

" Neocomplete
let g:neocomplete#enable_at_startup = 1

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
