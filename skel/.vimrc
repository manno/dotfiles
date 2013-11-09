"-----------------------------------------------------------
" MAIN VIMRC
"
colorscheme default
set nocompatible      " We're running Vim, not Vi!
set virtualedit=block " fix problem with yank in utf8
set wildmenu

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
syntax enable
filetype on                       " Enable filetype detection
filetype indent on                " Enable filetype-specific indenting
filetype plugin on                " Enable filetype-specific plugins
set hidden                        " Allow hidden buffers
set noinsertmode                  " don't don't out in insert mode
set backspace=indent,eol,start    " allow us to backspace before an insert

" jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

"----- Backups & Files
set backup                   " Enable creation of backup file.
set backupdir=~/.vim/backups " Where backups will go.
set directory=~/.vim/tmp     " Where temporary files will go.

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
else
     echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte"
endif

"----- GUI
if has("gui_running")
    set guifont=Monospace\ 11
endif

"----- VIMDIFF
if &diff
    syntax off
    " FIXME wrapping ?
    "set wrap
endif

"----- INCLUDES
source $HOME/.vim/config/functions.vim 
source $HOME/.vim/config/plugins.vim 
source $HOME/.vim/config/spelling.vim 
source $HOME/.vim/config/macros.vim 
source $HOME/.vim/config/keys_normal.vim 
source $HOME/.vim/config/statusline.vim 
source $HOME/.vim/config/vundle.vim 
