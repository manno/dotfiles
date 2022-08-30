-- vim: ts=2 sw=2
-- https://github.com/wbthomason/packer.nvim
-- https://github.com/nanotee/nvim-lua-guide

-- local function map(mode, lhs, rhs, opts)
--   local options = { noremap = false }
--   if opts then
--     options = vim.tbl_extend('keep', options, opts)
--   end
--   vim.keymap.set(mode, lhs, rhs, options)
-- end

-- local function noremap(mode, lhs, rhs, opts)
--   local options = { noremap = true }
--   if opts then
--     options = vim.tbl_extend('keep', options, opts)
--   end
--   vim.keymap.set(mode, lhs, rhs, options)
-- end
local silentOpt = { silent = true }
local allOpt = { noremap = true, silent = true, nowait = true }

-- Packer
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Parsers, replaces vim-polyglot
  -- TSInstall ft
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = {
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        ignore_install = { "phpdoc" },
        highlight = {
          enable = true,                 -- false will disable the whole extension
          -- disable = { "c", "rust" },  -- list of language that will be disabled
        },
      }
    }
  }

  -- Languageservers
  -- run :CocConfig to add language servers, e.g.
  -- run :CocCommand go.install.gopls
  --   go get -u golang.org/x/tools/...
  --   https://github.com/josa42/coc-go#example-configuration
  --   https://github.com/neoclide/coc.nvim/blob/master/data/schema.json
  -- run :CocUpdate
  -- run :CocInstall ft
  -- CocInstall coc-diagnostic
  use {
    'neoclide/coc.nvim',
    branch = 'release',
    run = ':CocInstall coc-go',
    config = function()
      vim.g.coc_global_extensions = { 'coc-json', 'coc-diagnostic', 'coc-tsserver', 'coc-go', 'coc-solargraph', 'coc-clangd', 'coc-yaml' }

      -- solargraph
      vim.g.coc_node_args = {'--dns-result-order=ipv4first'}

      -- https://github.com/neoclide/coc.nvim/blob/master/data/schema.json
      vim.keymap.set('', '<leader><F2>', ':CocConfig<CR>')

      -- -- <CR> confirms completion suggestion
      vim.keymap.set("i", "<CR>", "coc#pum#visible() ? coc#_select_confirm() : '<CR>'", {silent = true, expr = true, noremap = true})

      -- -- Use `[c` and `]c` to navigate diagnostics
      -- -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
      vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev)", silentOpt)
      vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next)", silentOpt)
      vim.keymap.set("n", "]d", "<Plug>(coc-definitions)", silentOpt)

      -- -- GoTo code navigation.
      vim.keymap.set("n", "gd", "<Plug>(coc-definition)", silentOpt)
      vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", silentOpt)
      vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", silentOpt)
      vim.keymap.set("n", "gr", "<Plug>(coc-references)", silentOpt)

      vim.keymap.set("n", "]f", "<Plug>(coc-fix-current)", silentOpt)
      vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)")
      -- -- \aw \aap \a%
      vim.keymap.set("x", "<leader>a", "<Plug>(coc-codeaction-selected)")
      vim.keymap.set("n", "<leader>a", "<Plug>(coc-codeaction-selected)")

      vim.keymap.set("n", "K", ":call CocActionAsync('doHover')<CR>", silentOpt)
      vim.keymap.set("n", "<leader>r", ":call CocActionAsync('rename')<CR>")

      -- Mappings for CoCList
      -- Show all diagnostics.
      vim.keymap.set("n", "<space>d", ":<C-u>CocList diagnostics<cr>", allOpt)
      -- Find symbol of current document.
      vim.keymap.set("n", "<space>o", ":<C-u>CocList outline<cr>", allOpt)

      -- Show commands.
      vim.keymap.set("n", "<space>c", ":<C-u>CocList commands<cr>", allOpt)
      -- Manage extensions.
      vim.keymap.set("n", "<space>e", ":<C-u>CocList extensions<cr>", allOpt)

      -- Search workspace symbols.
      vim.keymap.set("n", "<space>s", ":<C-u>CocList -I symbols<cr>", allOpt)
      -- Do default action for next item.
      vim.keymap.set("n", "<space>j", ":<C-u>CocNext<CR>", allOpt)
      -- Do default action for previous item.
      vim.keymap.set("n", "<space>k", ":<C-u>CocPrev<CR>", allOpt)
      -- Resume latest coc list.
      vim.keymap.set("n", "<space>p", ":<C-u>CocListResume<CR>", allOpt)
      --
      vim.keymap.set("n", "<space>a", "<Plug>(coc-codeaction-cursor)", { nowait = true, silent = true })

      local augroup = vim.api.nvim_create_augroup('coc', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'c,cpp,ruby',
        group = augroup,
        callback = function()
          vim.keymap.set("n", "gd", "<Plug>(coc-declaration)", silentOpt)
        end
      })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'c,cpp,go,ruby,rust',
        group = augroup,
        callback = function()
          vim.keymap.set("n", "<C-]>", "<Plug>(coc-definition)", silentOpt)
        end
      })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'go',
        group = augroup,
        callback = function()
          vim.keymap.set("n", "gtj", ":CocCommand go.tags.add json<cr>")
          vim.keymap.set("n", "gty", ":CocCommand go.tags.add yaml<cr>")
          vim.keymap.set("n", "gtx", ":CocCommand go.tags.clear<cr>")
        end
      })
    end
  }

  -- Open files
  local fzf_root = '~/.fzf'
  -- '/opt/homebrew/Cellar/fzf/0.33.0/'
  -- vim.trim(vim.fn.system('brew --prefix')) .. '/opt/fzf'
  use { fzf_root, as = 'fzf', run = 'cd ~/.fzf && ./install --bin' }
  use { "junegunn/fzf.vim", config = function()
    vim.keymap.set("", "<leader>t", ":GitFiles<CR>")
    vim.keymap.set("", "<leader>b", ":Buffers<CR>")
    vim.keymap.set("", "<leader>F", ":Rg<CR>")
  end}

  -- Status line
  use 'kyazdani42/nvim-web-devicons'
  use { 'akinsho/nvim-bufferline.lua', config = { require'bufferline'.setup{} } }
  use { 'hoob3rt/lualine.nvim', config = function() require('slanted-gaps') end }

  -- use 'romgrk/barbar.nvim'
  -- use {'folke/trouble.nvim', config = {
  --   require("trouble").setup{}
  --   -- how is that different from CocList diagnostics
  --   -- nnoremap <silent><nowait> <space>D  <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
  --   }
  -- }

  -- NerdCommenter
  use { 'scrooloose/nerdcommenter', config = function()
    vim.g.NERDSpaceDelims = 1
  end }

  -- Autocompletion
  use 'github/copilot.vim'

  -- Colorschemes
  use { 'jonathanfilip/vim-lucius', opt = true }
  use { 'tomasr/molokai', opt = true }
  use { 'noahfrederick/vim-hemisu', opt = true }
  use { 'endel/vim-github-colorscheme', opt = true }
  --use 'chriskempson/vim-tomorrow-theme'
  --use 'iCyMind/NeoSolarized'
  use { 'TroyFletcher/vim-colors-synthwave', opt = true }
  --use 'drewtempelmeyer/palenight.vim'
  --use {'embark-theme/vim', { as = 'embark' }}
  --use 'sainnhe/sonokai'
  use 'folke/tokyonight.nvim'

  -- Tmux integration
  use 'edkolev/tmuxline.vim'

  -- Readline style insertion
  use 'tpope/vim-rsi'

  -- Format SQL
  use 'vim-scripts/SQLUtilities'

  -- Surround - sa%" sa$' saE" srb" sr"' sd"
  --use 'machakann/vim-sandwich'
  use { 'kylechui/nvim-surround', config = {
      require("nvim-surround").setup({})
  }}

  -- Vim ruby
  use { 'tpope/vim-bundler', ft = {'ruby'} }
  use { 'tpope/vim-rake', ft = {'ruby'} }
  use { 'tpope/vim-rails', ft = {'ruby'} }
  use { 'janko-m/vim-test', config = function()
    vim.g['test#strategy'] = "neovim"
    vim.keymap.set("n", "<F3>", ":TestFile<CR>")
  end }

  -- Open files at line
  use 'manno/file-line'

  use { 'zerowidth/vim-copy-as-rtf', cond = function() return vim.fn.has('mac') end }

  -- Markdown preview
  use { 'davinche/godown-vim', ft = {'markdown'} }

  -- Git
  use { 'tpope/vim-fugitive', config = {
    vim.keymap.set("", "<leader>G", ":Ggrep <C-R><C-W> ':(exclude)*fake*'<CR>")
  }}

  use 'airblade/vim-gitgutter'

  -- Snippets
  use 'rafamadriz/friendly-snippets'
  use { 'L3MON4D3/LuaSnip', config = { require("luasnip.loaders.from_vscode").lazy_load() } }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
