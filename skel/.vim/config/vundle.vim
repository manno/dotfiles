call plug#begin('~/.vim/plugged')

" nerd
Plug 'The-NERD-Commenter'

" grep
"Plug 'vim-scripts/grep.vim'
Plug 'manno/grep'

" search with ag?
"Plug 'rking/ag.vim'

" taglist
"Plug 'taglist.vim'

" Status line
"Plug 'Lokaltog/vim-powerline'
Plug 'vim-airline'

" command-t - replace mbe,fuzzy
Plug 'git://git.wincent.com/command-t.git', { 'do': 'rvm use system; ruby extconf.rb && make clean && make'}

" tab completion
" Plug 'ervandew/supertab'

" you complete me - needs vim 7.3.584
" https://github.com/Valloric/YouCompleteMe
"Plug 'Valloric/YouCompleteMe'

" TODO neocomplete instead?
Plug 'Shougo/neocomplete.vim'

" syntax errors
Plug 'scrooloose/syntastic'

" Colorschemes
"Plug 'jonathanfilip/vim-lucius'
"Plug 'tomasr/molokai'
"Plug 'noahfrederick/vim-hemisu'
Plug 'endel/vim-github-colorscheme'

" ctags support
Plug 'vim-tags'

" Tmux integration
Plug 'edkolev/tmuxline.vim'

" Format SQL
Plug 'vim-scripts/SQLUtilities'
"Plug 'vim-scripts/Align'

" surround - yse' veS'
Plug 'tpope/vim-surround'

" vim ruby
" gem install gem-ctags
Plug 'tpope/vim-bundler', { 'for': 'ruby' }
Plug 'tpope/vim-rake', { 'for': 'ruby' }
Plug 'fatih/vim-go', { 'for': 'go' }

" file
Plug 'manno/file-line'

" Gvim Related
Plug 'airblade/vim-rooter'

" syntax
Plug 'vim-polyglot'

" Git
Plug 'fugitive.vim'

" latexsuite = vim-latex

call plug#end()
