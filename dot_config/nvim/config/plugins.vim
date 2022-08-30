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

" tpope/vim-fugitive
autocmd QuickFixCmdPost *grep* cwindow
set diffopt+=vertical

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
