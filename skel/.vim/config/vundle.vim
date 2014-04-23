"-----------------------------------------------------------
" VUNDLE
"
" apt-get install cmake python-dev
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

Bundle 'gmarik/vundle'

" nerd
Bundle 'The-NERD-Commenter'

" grep
"Bundle 'vim-scripts/grep.vim'
"Bundle 'yegappan/grep'
Bundle 'manno/grep'


" taglist
Bundle 'taglist.vim'

" minibufexplorer new
"Bundle 'fholgado/minibufexpl.vim'

" Status line
"Bundle 'Lokaltog/vim-powerline'
Bundle 'vim-airline'

" fuzzy dependency?
"Bundle 'L9'
"Bundle 'FuzzyFinder' " conflicts with fuzzy_finder_texmate?

" command-t - replace mbe,fuzzy
Bundle 'git://git.wincent.com/command-t.git'

" tab completion
" Bundle 'ervandew/supertab'

" you complete me - needs vim 7.3.584
" https://github.com/Valloric/YouCompleteMe
Bundle 'Valloric/YouCompleteMe'

" syntax errors
Bundle 'scrooloose/syntastic'

" tango colors
Bundle 'tango.vim'
Bundle 'baverman/vim-babymate256'

" Colorscheme
"Bundle 'Solarized'

" ctags support
"Bundle 'xolox/vim-easytags'
"Bundle 'xolox/vim-misc'

" Indent
Bundle 'IndentAnything'

" Tmux integration
Bundle 'edkolev/tmuxline.vim'

" Format SQL
Bundle 'vim-scripts/SQLUtilities'
Bundle 'vim-scripts/Align'

