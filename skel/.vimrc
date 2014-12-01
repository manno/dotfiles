"-----------------------------------------------------------
" MAIN VIMRC
"
set t_Co=256
syntax enable
set synmaxcol=2048 " hugefiles
colorscheme default
hi DiffText       term=reverse cterm=bold ctermbg=9 ctermfg=white

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

"----- MOUSE
if has("mouse")
    set mouse=vihr          " mouse in insert/visual/help mode only
endif

"----- SEARCH
set ignorecase
set smartcase
set incsearch               " show `best match so far' as typed
set hlsearch                " keep highlight until :noh

"----- ENCODING
set nodigraph               " you need digraphs for uumlauts
if has("multi_byte")        " vim tip 245
     set encoding=utf-8     " how vim shall represent characters internally
     set fileencodings=utf-8,iso-8859-15,ucs-bom    " heuristic
     set virtualedit=block " fix problem with yank in utf8
else
     echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte"
endif

"----- GUI
if has("gui_running")
    set guifont=Monospace\ 9
    set guioptions-=m        " remove menu bar
    set guioptions-=T        " remove tool bar
    set guioptions-=r
    set guioptions-=L
endif

"----- VIMDIFF
if &diff
    "syntax off
    " FIXME wrapping ?
    "set wrap
    set diffopt+=iwhite
endif

"----- STATUSLINE
set laststatus=2
set ruler
set showcmd                 " show the command in the status line

"----- INCLUDES
source $HOME/.vim/config/spelling.vim 
source $HOME/.vim/config/keys.vim 
source $HOME/.vim/config/vundle.vim 
source $HOME/.vim/config/plugins.vim 
