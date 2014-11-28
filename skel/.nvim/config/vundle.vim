"-----------------------------------------------------------
" VUNDLE
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

" taglist
Bundle 'taglist.vim'

" Status line
"Bundle 'Lokaltog/vim-powerline'
Bundle 'vim-airline'

" command-t - replace mbe,fuzzy
Bundle 'git://git.wincent.com/command-t.git'

" ctrlP? i hate it - so slow, hard to control
"Bundle 'ctrlp.vim'

" tab completion
" Bundle 'ervandew/supertab'

" you complete me - needs vim 7.3.584
" https://github.com/Valloric/YouCompleteMe
"Bundle 'Valloric/YouCompleteMe'

" syntax errors
Bundle 'scrooloose/syntastic'

" Colorschemes
" tango colors
Bundle 'tango.vim'

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
Bundle 'bogado/file-line'

" Gvim Related
Bundle 'airblade/vim-rooter'

" syntax
Bundle 'vim-polyglot'

" Git
Bundle 'fugitive.vim'

" latexsuite = vim-latex

