" ----- Plug
" Auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.config/nvim/plugged')

" Nerd
Plug 'scrooloose/nerdcommenter'

" Grep
"Plug 'vim-scripts/grep.vim'
"Plug 'manno/grep'

" Search with ag?
"Plug 'rking/ag.vim'

" Status line
Plug 'kyazdani42/nvim-web-devicons'
Plug 'akinsho/nvim-bufferline.lua'
Plug 'hoob3rt/lualine.nvim'
"Plug 'romgrk/barbar.nvim'
"Plug 'folke/trouble.nvim'

" Open files
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'

" Languageservers
" run :CocConfig to add language servers, e.g.
" run :CocCommand go.install.gopls
"   go get -u golang.org/x/tools/...
"   https://github.com/josa42/coc-go#example-configuration
"   https://github.com/neoclide/coc.nvim/blob/master/data/schema.json
" run :CocUpdate
" run :CocInstall ft
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': ':CocInstall coc-go'}
" CocInstall coc-diagnostic
let g:coc_global_extensions=['coc-json',
                           \ 'coc-diagnostic',
                           \ 'coc-tsserver',
                           \ 'coc-go',
                           \ 'coc-solargraph',
                           \ 'coc-clangd',
                           \ 'coc-yaml' ]

" Colorschemes
Plug 'jonathanfilip/vim-lucius'
Plug 'tomasr/molokai'
Plug 'noahfrederick/vim-hemisu'
Plug 'endel/vim-github-colorscheme'
"Plug 'chriskempson/vim-tomorrow-theme'
"Plug 'iCyMind/NeoSolarized'
Plug 'TroyFletcher/vim-colors-synthwave'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'embark-theme/vim', { 'as': 'embark' }
Plug 'sainnhe/sonokai'
Plug 'folke/tokyonight.nvim'

" Tmux integration
Plug 'edkolev/tmuxline.vim'

" Readline style insertion
Plug 'tpope/vim-rsi'

" Format SQL
Plug 'vim-scripts/SQLUtilities'
Plug 'vim-scripts/Align'

" Surround - sa$' srb" sd"
Plug 'machakann/vim-sandwich'

" Vim ruby
Plug 'tpope/vim-bundler', { 'for': 'ruby' }
Plug 'tpope/vim-rake', { 'for': 'ruby' }
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'janko-m/vim-test'

" Open files at line
Plug 'manno/file-line'

if has('macunix')
    Plug 'zerowidth/vim-copy-as-rtf'
endif

" Markdown preview
Plug 'davinche/godown-vim', { 'for': 'markdown' }

" Parsers, replaces vim-polyglot
" TSUpdate
" TSInstall ft
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

call plug#end()

" ----- Colorschemes
if $ITERM_PROFILE=="Light Default"
    "colorscheme hemisu
    "colorscheme lucius
    colorscheme github
" elseif !empty($TMUX)
"     colorscheme hemisu
else
    "colorscheme synthwave
    "colorscheme hemisu
    "colorscheme lucius
    "LuciusBlackHighContrast
    "colorscheme embark
    "let g:rehash256 = 1
    "colorscheme molokai

    " let g:sonokai_style = 'shusia'
    " let g:sonokai_enable_italic = 1
    " let g:sonokai_disable_italic_comment = 1
    " colorscheme sonokai

    let g:tokyonight_style = 'night'
    colorscheme tokyonight
endif

" ----- Plugin Configurations

" Search
map <leader>G     :Ggrep <C-R><C-W> ':(exclude)*fake*'<CR>


" vim-test
nmap <F3> :TestFile<CR>
let test#strategy = "neovim"

" fugitive git grep
autocmd QuickFixCmdPost *grep* cwindow
set diffopt+=vertical

" NERDCommenter
let NERDSpaceDelims = 1

if match(&runtimepath, 'nvim-bufferline') != -1
    lua require'bufferline'.setup{}
end

if match(&runtimepath, 'trouble') != -1
lua <<EOF
  require("trouble").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
EOF
" how is that different from CocList diagnostics
nnoremap <silent><nowait> <space>D  <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
end

" coc
" https://github.com/neoclide/coc.nvim/blob/master/data/schema.json
map   <leader><F2>      :CocConfig<CR>

" Use `[c` and `]c` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> ]d <Plug>(coc-definitions)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <silent> ]f <Plug>(coc-fix-current)
nmap <leader>rn <Plug>(coc-rename)
" \aw \aap \a%
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

nmap <silent> K  :call CocActionAsync('doHover')<CR>
nmap <leader>r  :call CocActionAsync('rename')<CR>

autocmd FileType c,cpp,ruby nmap <silent> gd <Plug>(coc-declaration)
autocmd FileType c,cpp,go,ruby,rust nmap <silent> <C-]> <Plug>(coc-definition)
autocmd FileType go nmap gtj :CocCommand go.tags.add json<cr>
autocmd FileType go nmap gty :CocCommand go.tags.add yaml<cr>
autocmd FileType go nmap gtx :CocCommand go.tags.clear<cr>

" solargraph
let g:coc_node_args = ['--dns-result-order=ipv4first']

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>d  :<C-u>CocList diagnostics<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>

" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>

" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
"
nmap <silent><nowait> <space>a  <Plug>(coc-codeaction-cursor)

" ----- fzf
map <leader>t :GitFiles<CR>
map <leader>b :Buffers<CR>
map <leader>F :Rg<CR>

" fzf grep
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
map <leader>g     :GGrep <C-R><C-W><CR>

" floating fzf (https://github.com/junegunn/fzf.vim/issues/664)
let $FZF_DEFAULT_OPTS .= ' --layout=reverse'

function! FloatingFZF()
	let height = &lines
	let width = float2nr(&columns - (&columns * 2 / 10))
	let col = float2nr((&columns - width) / 2)
	let col_offset = &columns / 10
	let opts = {
				\ 'relative': 'editor',
				\ 'row': 1,
				\ 'col': col + col_offset,
				\ 'width': width * 2 / 1,
				\ 'height': height / 2,
				\ 'style': 'minimal'
				\ }
	let buf = nvim_create_buf(v:false, v:true)
	let win = nvim_open_win(buf, v:true, opts)
	call setwinvar(win, '&winhl', 'NormalFloat:TabLine')
endfunction

"let g:fzf_layout = { 'up': '~50%' }
let g:fzf_layout = { 'window': 'call FloatingFZF()' }

if $ITERM_PROFILE=="Light Default"
    highlight TabLine ctermbg=white
"else
"    highlight TabLine ctermbg=black
endif

" Syntax highlight
if match(&runtimepath, 'nvim-treesitter') != -1
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
  },
}
EOF
end
