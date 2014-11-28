"-----------------------------------------------------------
" MAIN VIMRC
"
colorscheme default
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
    set guifont=Monospace\ 9
    set guioptions-=m        " remove menu bar
    set guioptions-=T        " remove tool bar
    set guioptions-=r
    set guioptions-=L
endif

"----- VIMDIFF
if &diff
    syntax off
    " FIXME wrapping ?
    "set wrap
    set diffopt+=iwhite
endif

" if has('neovim')
"     let s:python_host_init = 'python -c "import neovim; neovim.start_host()"'
"     let &initpython = s:python_host_init
" endif
autocmd FileType c nnoremap <buffer> <silent> <C-]> :YcmCompleter GoTo<cr>

"----- INCLUDES
source $HOME/.nvim/config/spelling.vim 
source $HOME/.nvim/config/keys_normal.vim 
source $HOME/.nvim/config/vundle.vim 
source $HOME/.nvim/config/statusline.vim 
source $HOME/.nvim/config/plugins.vim 
