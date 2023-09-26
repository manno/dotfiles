vim.cmd [[
autocmd QuickFixCmdPost *grep* cwindow
set diffopt+=vertical
]]

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
vim.keymap.set({'n', 'v'}, '<leader>g', function()
    require('git_grep').grep()
end)
vim.keymap.set('n', '<leader>G', function()
    require('git_grep').live_grep()
end)
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>t', builtin.git_files, {})
vim.keymap.set('n', '<leader>F', builtin.find_files, {})
vim.keymap.set('n', '<leader>s', builtin.symbols, {})
