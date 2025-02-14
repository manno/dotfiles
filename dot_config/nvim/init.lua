-- Mouse
vim.o.mouse = "ivh"

-- Setup tabs, use spaces instead of tabs
vim.o.shiftround = true
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.cf = true        -- Enable error files & error jumping.
vim.o.autowrite = true -- Writes on make/shell commands
vim.o.number = true    -- Show line numbers

-- Stop highlighting after a certain column
vim.o.synmaxcol = 2048

-- Setup document specifics
vim.cmd('filetype on')      -- Load filetype.vim
vim.o.hidden = true         -- Allow hidden buffers
vim.o.wildignore =  '*.o,*.obj,.svn,.git,tags'
vim.o.wildignore = vim.o.wildignore .. ',blue.vim,darkblue.vim,delek.vim,desert.vim,elflord.vim,evening.vim,habamax.vim,industry.vim,koehler.vim,lunaperche.vim,morning.vim,murphy.vim,pablo.vim,peachpuff.vim,quiet.vim,retrobox.vim,ron.vim,shine.vim,slate.vim,sorbet.vim,torte.vim,wildcharm.vim,zaibatsu.vim,zellner.vim'

-- Jump to the last position when reopening a file
vim.api.nvim_exec([[
  augroup jump_to_last_position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif
  augroup END
]], false)

-- Backups & Files
vim.o.backup = true                  -- Enable creation of a backup file.
vim.api.nvim_exec([[
if empty(glob('~/.local/share/nvim/backup'))
    call mkdir($HOME . "/.local/share/nvim/backup", "p", 0700)
endif
]], false)
vim.o.backupdir = vim.fn.expand('~/.local/share/nvim/backup') -- Where backups will go.
vim.o.undofile = true                -- Persistent undo
vim.o.undolevels = 1000               -- Maximum number of changes that can be undone
vim.o.undoreload = 10000              -- Maximum number of lines to save for undo on a buffer reload

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'nosplit' -- Split?

-- Encoding
vim.o.digraph = false
vim.o.virtualedit = 'block' -- Fix problem with yank in utf8

-- Diffmode
if vim.o.diff then
    vim.o.syntax = 'off'
    vim.o.diffopt = vim.o.diffopt .. ',iwhite'
end

-- Quickfix
vim.cmd [[
autocmd QuickFixCmdPost *grep* cwindow
set diffopt+=vertical
]]

-- Statusline
vim.o.showcmd = true -- Show the command in the status line

if vim.fn.has('termguicolors') == 1 then
    vim.o.termguicolors = true
end

if vim.fn.has("nvim-0.5.0") == 1 then
    -- merge signcolumn and number column into one
    vim.o.signcolumn = 'number'
end

-- Don't show quickfix in buffer list
vim.api.nvim_exec([[
  augroup QFix
    autocmd!
    autocmd FileType qf setlocal nobuflisted
  augroup END
]], false)

-- Spelling
vim.api.nvim_exec([[
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

  nnoremap <F8> :set spell spelllang=en,de<CR>:call WordProcessor(1)<CR>
  nnoremap <s-F8> :setlocal spell spelllang=de_20,de,en<CR>:call WordProcessor(1)<CR>
  nnoremap <esc><F8> :setlocal nospell<CR>:call WordProcessor(0)<CR>

  set thesaurus+=~/.config/nvim/spell/thesaurus.txt
]], false)

-- Keys / Mappings / Commands
vim.api.nvim_set_keymap('n', '<F5>', ':set paste!<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-n>', ':bn<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-p>', ':bp<CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>n', ':tabnext<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>p', ':tabprev<CR>', { noremap = true })

vim.o.fileignorecase = false
--  get rid of netrw, can't close its buffer
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

vim.api.nvim_set_keymap('n', '<leader>W', ':close<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>D', ':%bd!<CR>', { noremap = true })

vim.api.nvim_set_keymap('t', '<A-h>', '<C-\\><C-n><C-w>h', { noremap = true })
vim.api.nvim_set_keymap('t', '<A-j>', '<C-\\><C-n><C-w>j', { noremap = true })
vim.api.nvim_set_keymap('t', '<A-k>', '<C-\\><C-n><C-w>k', { noremap = true })
vim.api.nvim_set_keymap('t', '<A-l>', '<C-\\><C-n><C-w>l', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w>l', { noremap = true })

-- Debug
vim.api.nvim_set_keymap('n', '<F6>', ':command', { noremap = true })
vim.api.nvim_set_keymap('n', '<F2>', ':n ~/.config/nvim/lua/plugins.lua ~/.config/nvim/init.lua ~/.config/nvim/filetype.vim<CR>', { noremap = true })

-- Make
vim.api.nvim_set_keymap('n', '!ma', '<ESC>:w<CR>:make %<CR>', { noremap = true })

-- Forgot to open as root?
vim.cmd('command! Wsudo :w !sudo tee > /dev/null %')

vim.cmd('command! Tidy :%!/opt/tidy-html5/bin/tidy -w -i -q -f /dev/null')

-- Format json
vim.cmd('command! -range FormatJSON <line1>,<line2>!python -m json.tool')

-- ----- Converter Mappings -----
--
-- Convert to html
vim.api.nvim_set_keymap('n', '_th', ':source $VIMRUNTIME/syntax/2html.vim<CR>', { noremap = true, silent = true })
-- convert to colored tex, use TMiniBufExplorer first
vim.api.nvim_set_keymap('n', '_tt', ':source $VIMRUNTIME/syntax/2tex.vim<CR>', { noremap = true, silent = true })
-- convert to colored ansi
vim.api.nvim_set_keymap('v', '_ta', ':TOansi<CR>', { noremap = true, silent = true })

-- Shift + J/K moves selected lines down/up in visual mode
-- vim.api.nvim_set_keymap('x', 'J', ':m \'>+1<CR>gv=gv', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('x', 'K', ':m \'<-2<CR>gv=gv', { noremap = true, silent = true })

-- yy vs y$
-- vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true, silent = true })

-- ----- Filetype Specific Settings -----
vim.api.nvim_exec([[
augroup languages
    " autocmd FileType csv       set nofoldenable
    " autocmd FileType xml       let g:xml_syntax_folding = 1
    autocmd FileType c           set cindent
    autocmd FileType eruby       map _rw i<%= %>
    autocmd FileType eruby       set number
    " autocmd FileType go        map <F4> :GoImports<CR>
    autocmd FileType go          setlocal noet ts=8 sw=8 sts=8 number
    " autocmd FileType go        set completeopt-=preview
    autocmd BufWritePre *.go     :silent call CocAction('runCommand', 'editor.action.organizeImport')
    autocmd FileType java        set foldmethod=manual
    autocmd FileType lua         set ts=4 sw=4 et smartindent foldmethod=syntax
    autocmd FileType nfo         edit ++enc=cp437
    autocmd FileType nfo         silent edit ++enc=cp437
    autocmd FileType ruby        set number foldmethod=manual
    autocmd FileType vim         set ts=4 sw=4
    autocmd FileType xml         set ts=4 sw=4
    autocmd FileType xwt         set foldmethod=syntax
    autocmd FileType zsh         set ts=4 sw=4 et
    autocmd filetype crontab     setlocal nobackup nowritebackup

    " strip trailing whitespace
    autocmd FileType c,vim,ruby,lua,yaml,haml,css,html,eruby,coffee,javascript,markdown,sh,python autocmd BufWritePre <buffer> :%s/\s\+$//e
augroup END
]], false)

-- ----- Plugins

require('plugins')
