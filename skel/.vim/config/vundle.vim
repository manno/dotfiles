"-----------------------------------------------------------
" VUNDLE
"
" apt-get install cmake python-dev
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

" FIXME directory isn't a git checkout, no update possible
" rm -fr ~/vim/bundle/vundle && git clone --recursive https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
"Bundle 'gmarik/vundle'

" nerd
Bundle 'The-NERD-Commenter'

" super-tab
Bundle 'ervandew/supertab'

Bundle 'Lokaltog/vim-powerline'

" fuzzy
Bundle 'L9'
" conflicts with fuzzy_finder_texmate?
"Bundle 'FuzzyFinder'

" you complete me - needs vim 7.3.584
" Bundle 'YMC'

