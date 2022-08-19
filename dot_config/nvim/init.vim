" ----- Mouse
"disable normal mode, so terminal can copy
set mouse=ivh

"----- Setup tabs, use spaces instead of tabs
set shiftround
set softtabstop=2
set shiftwidth=2
set tabstop=2
set expandtab
set cf                " Enable error files & error jumping.
set autowrite         " Writes on make/shell commands
set number            " Show line numbers

"----- stop highlighting after
set synmaxcol=2048

"----- Setup document specifics
filetype on                       " Load filetype.vim
set hidden                        " Allow hidden buffers
set wildignore+=*.o,*.obj,.svn,.git,tags

" Jump to the last position when reopening a file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
            \| exe "normal g'\"" | endif

"----- Backups & Files
set backup                  " Enable creation of backup file.
if empty(glob('~/.local/share/nvim/backup'))
    call mkdir($HOME . "/.local/share/nvim/backup", "p", 0700)
endif
set backupdir=~/.local/share/nvim/backup " Where backups will go.
set undofile                " So is persistent undo ...
set undolevels=1000         " Maximum number of changes that can be undone
set undoreload=10000        " Maximum number lines to save for undo on a buffer reload

"----- Search
set ignorecase
set smartcase
set inccommand=nosplit "split?

"----- Encoding
set nodigraph               " Disable digraphs for uumlauts
set fileencodings=utf-8,iso-8859-15,ucs-bom    " heuristic
set virtualedit=block  " Fix problem with yank in utf8

"----- Diffmode
if &diff
    syntax off
    "set wrap
    set diffopt+=iwhite
    " do/dp
    " 1do
    " map <leader>1 :diffget LOCAL<CR>
    " 2do
    " map <leader>2 :diffget BASE<CR>
    " 3do
    " map <leader>3 :diffget REMOTE<CR>
endif

"----- Statusline
set showcmd                 " show the command in the status line

if has('termguicolors')
    set termguicolors
endif

if has("nvim-0.5.0")
  " merge signcolumn and number column into one
  set signcolumn=number
end

" don't show quickfix in buffer list
augroup QFix
    autocmd!
    autocmd FileType qf setlocal nobuflisted
augroup END

" ----- Spelling
"
" Rechtschreibung & Word Processing: move cursor in editor lines, not text lines
" change to utf8 umlaut compatible mode with digraphs
" http://vim.wikia.com/wiki/VimTip38
function! WordProcessor(enable)
  if a:enable
    echo "WordProcessor Mode: enabled"
    imap <Up> <C-O>gk
    imap <Down> <C-O>gj
    imap <k> <C-O>gk
    imap <j> <C-O>gj
  else
    echo "WordProcessor Mode: disabled"
    silent! iunmap <Up>
    silent! iunmap <Down>
    silent! iunmap <k>
    silent! iunmap <j>
  endif
endfunction

" disable arrow keys to learn hjkl
" noremap <Up> <Nop>
" noremap <Down> <Nop>
" noremap <Left> <Nop>
" noremap <Right> <Nop>

" German spelling
map <F8>        :setlocal spell spelllang=de_20,de,en<CR>:call WordProcessor(1)<CR>
map <s-F8>      :setlocal spell spelllang=en<CR>:call WordProcessor(1)<CR>
map <esc><F8>   :setlocal nospell<CR>:call WordProcessor(0)<CR>

set thesaurus+=~/.config/nvim/spell/thesaurus.txt

" ----- Keys / Mappings / Commands
"
" Change map leader, default is \
"let mapleader = ","

" Famous paste toggle for xterm vim
set pastetoggle=<F5>

" Buffer next/prev
nnoremap <C-n>   :bn<CR>
nnoremap <C-p>   :bp<CR>

" Tab next
nnoremap <leader>n   :tabnext<CR>
nnoremap <leader>p   :tabprev<CR>

" Close current buffer
nnoremap <leader>w       :bw<CR>
nnoremap <leader>D       :%bd!<CR>

" Terminal
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Debug
map   <F6>      :command
" :so %
map   <F2>      :n ~/.config/nvim/config/plugins.vim ~/.config/nvim/init.vim ~/.config/nvim/filetype.vim ~/.config/nvim/config/m1.vim<CR>

" Make
map !ma       <ESC>:w<CR>:make %<CR>

" Forgot to open as root?
command! Wsudo  :w !sudo tee > /dev/null %

command! Tidy :%!/opt/tidy-html5/bin/tidy -w -i -q -f /dev/null

" Format json
com! -range FormatJSON <line1>,<line2>!python -m json.tool

" ----- Converter Mappings
"
" Convert to html
map  _th     :source $VIMRUNTIME/syntax/2html.vim
" convert to colored tex, use TMiniBufExplorer first
map  _tt     :source $VIMRUNTIME/syntax/2tex.vim
" convert to colored ansi
vmap _ta     :TOansi

" Shift + J/K moves selected lines down/up in visual mode
"vnoremap J :m '>+1<CR>gv=gv
"vnoremap K :m '<-2<CR>gv=gv

" yy vs y$
" unmap Y

" ----- Filetype Specific Settings
"
augroup languages
"autocmd FileType csv          set nofoldenable
"autocmd FileType xml          let g:xml_syntax_folding = 1
autocmd FileType c            set cindent
autocmd FileType eruby        map _rw i<%= %>
autocmd FileType eruby        set number
"autocmd FileType go           map <F4> :GoImports<CR>
autocmd FileType go           setlocal noet ts=8 sw=8 sts=8 number
"autocmd FileType go           set completeopt-=preview
autocmd FileType java         set foldmethod=manual
autocmd FileType lua          set ts=4 sw=4 et smartindent foldmethod=syntax
autocmd FileType nfo          edit ++enc=cp437
autocmd FileType nfo          silent edit ++enc=cp437
autocmd FileType ruby         set number foldmethod=manual
autocmd FileType vim          set ts=4 sw=4
autocmd FileType xml          set ts=4 sw=4
autocmd FileType xwt          set foldmethod=syntax
autocmd FileType zsh          set ts=4 sw=4 et
autocmd filetype crontab setlocal nobackup nowritebackup

" strip trailing whitespace
autocmd FileType c,vim,ruby,yaml,haml,css,html,eruby,coffee,javascript,markdown,sh,python autocmd BufWritePre <buffer> :%s/\s\+$//e
augroup END

augroup netrw
autocmd FileType netrw nnoremap <buffer><silent> <Esc> :call <SID>CloseNetrw()<CR>
autocmd FileType netrw nnoremap <buffer><silent> q     :call <SID>CloseNetrw()<CR>
augroup END

function! s:CloseNetrw() abort
  for bufn in range(1, bufnr('$'))
    if bufexists(bufn) && getbufvar(bufn, '&filetype') ==# 'netrw'
      silent! execute 'bwipeout ' . bufn
      if getline(2) =~# '^" Netrw '
        silent! bwipeout
      endif
      return
    endif
  endfor
endfunction


" ----- Plugins
"
runtime config/plugins.vim
if match(&runtimepath, 'lualine') != -1
  lua require('slanted-gaps')
end
runtime config/m1.vim
"lua require('manno/plugins')
