---@diagnostic disable: undefined-global, undefined-field
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
vim.o.completeopt = 'menuone,noselect,fuzzy,nosort'

-- Stop highlighting after a certain column
vim.o.synmaxcol = 2048

-- Setup document specifics
vim.cmd('filetype on') -- Load filetype.vim
vim.o.hidden = true    -- Allow hidden buffers
vim.o.wildignore = '*.o,*.obj,.svn,.git,tags'
vim.o.wildignore = vim.o.wildignore ..
    ',blue.vim,darkblue.vim,delek.vim,desert.vim,elflord.vim,evening.vim,habamax.vim,industry.vim,koehler.vim,lunaperche.vim,morning.vim,murphy.vim,pablo.vim,peachpuff.vim,quiet.vim,retrobox.vim,ron.vim,shine.vim,slate.vim,sorbet.vim,torte.vim,wildcharm.vim,zaibatsu.vim,zellner.vim'

-- Jump to the last position when reopening a file
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('jump_to_last_position', { clear = true }),
  pattern = '*',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- Backups & Files
vim.o.backup = true -- Enable creation of a backup file.
vim.api.nvim_exec([[
if empty(glob('~/.local/share/nvim/backup'))
    call mkdir($HOME . "/.local/share/nvim/backup", "p", 0700)
endif
]], false)
vim.o.backupdir = vim.fn.expand('~/.local/share/nvim/backup') -- Where backups will go.
vim.o.undofile = true                                         -- Persistent undo
vim.o.undolevels = 1000                                       -- Maximum number of changes that can be undone
vim.o.undoreload = 10000                                      -- Maximum number of lines to save for undo on a buffer reload

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'nosplit' -- Split?

-- Encoding
vim.o.digraph = false
vim.o.virtualedit = 'block' -- Fix problem with yank in utf8

-- Diffmode
vim.opt.diffopt = {
    "internal",
    "filler",
    "closeoff",

    "context:12",
    "algorithm:histogram",
    "linematch:200",
    "indent-heuristic",
    --"iwhite",
}

-- Statusline
vim.o.showcmd = true -- Show the command in the status line

if vim.fn.has('termguicolors') == 1 then
    vim.o.termguicolors = true
end

if vim.fn.has("nvim-0.5.0") == 1 then
    -- merge signcolumn and number column into one
    vim.o.signcolumn = 'number'
end


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

-- Dynamic completion file selection for F2
local function get_completion_file()
  local completion_type = vim.env.NVIM_COMPLETION or "vanilla"
  if completion_type == "copilot" then
    return "completion-copilot"
  elseif completion_type == "minuet" then
    return "completion-minuet"
  else
    return "completion"
  end
end

vim.keymap.set('n', '<F2>', function()
  local completion_file = get_completion_file()
  local files = {
    '~/.config/nvim/lua/plugins.lua',
    '~/.config/nvim/lua/lsp.lua',
    '~/.config/nvim/lua/plugins/' .. completion_file .. '.lua',
    '~/.config/nvim/init.lua'
  }

  -- Add assistance.lua if enabled
  if vim.env.NVIM_ASSISTANCE == "true" then
    table.insert(files, 3, '~/.config/nvim/lua/plugins/assistance.lua')
  end

  vim.cmd(':n ' .. table.concat(files, ' '))
end, { noremap = true })

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

-- yy vs y$
-- vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true, silent = true })

-- ----- Filetypes
vim.filetype.add({
  extension = {
    coffee = 'coffee',
    es6 = 'javascript',
    jbuilder = 'ruby',
    mirah = 'ruby',
    nfo = 'nfo',
    prawn = 'ruby',
    prolog = 'prolog',
    rhtml = 'eruby',
    tt = 'html',
    txt = 'text',
    wiki = 'Wikipedia',
    xwt = 'xml',
  },
  filename = {
    PKGBUILD = 'sh',
  },
  pattern = {
    ['svn%-commit%..*'] = 'svn',
    ['svn%-log%..*'] = 'svn',
  },
})

-- Don't show quickfix in buffer list
vim.api.nvim_create_augroup('QFix', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  command = 'setlocal nobuflisted',
  group = 'QFix',
})

-- ----- Filetype Specific Settings -----
local group = vim.api.nvim_create_augroup('languages', { clear = true })

vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'c', command = 'setlocal cindent' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'eruby', command = 'setlocal number | map <buffer> _rw i<%= %>' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'go', command = 'setlocal noet ts=8 sw=8 sts=8 number' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'java', command = 'setlocal foldmethod=manual' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'lua', command = 'setlocal ts=4 sw=4 et smartindent foldmethod=syntax' })
vim.api.nvim_create_autocmd('BufReadPost', { group = group, pattern = '*.nfo', command = 'edit ++enc=cp437' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'ruby', command = 'setlocal number foldmethod=manual' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = { 'vim', 'xml' }, command = 'setlocal ts=4 sw=4' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'xwt', command = 'setlocal foldmethod=syntax' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'zsh', command = 'setlocal ts=4 sw=4 et' })
vim.api.nvim_create_autocmd('FileType', { group = group, pattern = 'crontab', command = 'setlocal nobackup nowritebackup' })

-- Strip trailing whitespace
vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  pattern = { '*.c', '*.vim', '*.ruby', '*.lua', '*.yaml', '*.haml', '*.css', '*.html', '*.eruby', '*.coffee', '*.javascript', '*.js', '*.md', '*.sh', '*.zsh', '*.py' },
  command = '%s/\\s\\+$//e'
})

-- ----- Plugins

require('lsp')
require('plugins')
