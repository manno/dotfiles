-- vim: ts=2 sw=2
-- https://github.com/wbthomason/packer.nvim
-- https://github.com/nanotee/nvim-lua-guide

local silentOpt = { silent = true }
local allOpt = { noremap = true, silent = true, nowait = true }

-- Packer
-- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
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

-- https://github.com/wbthomason/packer.nvim#specifying-plugins
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Parsers, replaces vim-polyglot
  -- TSInstall ft
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        ignore_install = { "phpdoc" },
        highlight = {
          enable = true,                 -- false will disable the whole extension
          -- disable = { "c", "rust" },  -- list of language that will be disabled
        },
        textobjects = {
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]]"] = "@function.outer",
              ["]m"] = "@class.outer",
            },
            goto_next_end = {
              ["]["] = "@function.outer",
              ["]M"] = "@class.outer",
            },
            goto_previous_start = {
              ["[["] = "@function.outer",
              ["[m"] = "@class.outer",
            },
            goto_previous_end = {
              ["[]"] = "@function.outer",
              ["[M"] = "@class.outer",
            },
          },
        },
      }
    end
  }
  use { 'nvim-treesitter/nvim-treesitter-textobjects' }
  use { 'nvim-treesitter/nvim-treesitter-context' }

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
      vim.g.coc_global_extensions = { 'coc-json', 'coc-diagnostic', 'coc-tsserver', 'coc-go', 'coc-solargraph', 'coc-clangd', 'coc-yaml', 'coc-lua' }

      -- solargraph
      vim.g.coc_node_args = {'--dns-result-order=ipv4first'}

      -- https://github.com/neoclide/coc.nvim/blob/master/data/schema.json
      vim.keymap.set('', '<leader><F2>', ':CocConfig<CR>')

      -- -- <CR> confirms completion suggestion
      local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
      vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
      vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

      -- Make <CR> to accept selected completion item or notify coc.nvim to format
      -- <C-g>u breaks current undo, please make your own choice.
      vim.keymap.set("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

      -- Use `[c` and `]c` to navigate diagnostics
      -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
      vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev)", silentOpt)
      vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next)", silentOpt)
      vim.keymap.set("n", "]d", "<Plug>(coc-definitions)", silentOpt)

      -- GoTo code navigation.
      vim.keymap.set("n", "gd", "<Plug>(coc-definition)", silentOpt)
      vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", silentOpt)
      vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", silentOpt)
      vim.keymap.set("n", "gr", "<Plug>(coc-references)", silentOpt)

      vim.keymap.set("n", "]f", "<Plug>(coc-fix-current)", silentOpt)
      vim.keymap.set("n", "K", ":call CocActionAsync('doHover')<CR>", silentOpt)

      vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)")
      vim.keymap.set("n", "<leader>R", ":call CocActionAsync('rename')<CR>")

      -- \aw \aap \a%
      vim.keymap.set("x", "<leader>a", "<Plug>(coc-codeaction-selected)")
      vim.keymap.set("n", "<leader>a", "<Plug>(coc-codeaction-selected)")


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

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    requires = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-telescope/telescope-fzf-native.nvim',
                 run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
            { "davvid/telescope-git-grep.nvim", tag = "v1.0.2" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = require("telescope.actions").close,
            },
          },
        },
      })
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
      -- treesitter, tags, registers
      vim.keymap.set('n', '<leader>T', builtin.treesitter, {})
      vim.keymap.set('n', '<leader>F', builtin.find_files, {})
      vim.keymap.set('n', '<leader>s', builtin.symbols, {})
      vim.keymap.set('n', '<leader>p', builtin.planets, {})
      vim.keymap.set('n', '<leader>r', builtin.registers, {})
      vim.keymap.set('n', '<leader>j', builtin.jumplist, {})
      vim.keymap.set('n', '<leader>d', builtin.diagnostics, {})
    end
  }

  use 'nvim-telescope/telescope-symbols.nvim'

  -- Status line
  use 'nvim-tree/nvim-web-devicons' -- OPTIONAL: for file icons

  use 'lewis6991/gitsigns.nvim' -- OPTIONAL: for git status
  use { 'romgrk/barbar.nvim', config = function()
      vim.keymap.set('', '<leader>w', ':BufferWipeout<cr>')
      vim.keymap.set('', '<C-n>', ':BufferNext<cr>')
      vim.keymap.set('', '<C-p>', ':BufferPrevious<cr>')
  end }

  use { 'hoob3rt/lualine.nvim', config = function()
    require("lualine").setup({
      options = {
        theme = 'auto',
        globalstatus = true,
      },
      sections = {
        lualine_b = {'windows', 'diff', 'diagnostics'},
        lualine_c = {
          {
            'filename',
            file_status = true,
            newfile_status = true,
            path = 1,
            shorting_target = 20,
          }
        },
        lualine_y = {'searchcount', 'progress'},
      }
    })
  end }

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
  use { 'github/copilot.vim', ft = {'ruby', 'go', 'js', 'sh', 'lua', 'vim', 'yaml'} }

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
  use { 'folke/tokyonight.nvim', config = function()
    -- vim.cmd[[colorscheme tokyonight]]
  end }

  use { 'sontungexpt/witch', config = function(_, opts)
    --require("witch").setup(opts)
    --vim.cmd[[colorscheme witch]]
  end }

  use { 'binhtran432k/dracula.nvim', config = function(_, opts)
    require("dracula").setup(opts)
    vim.cmd[[colorscheme dracula]]
  end }

  -- Tmux integration
  use { 'edkolev/tmuxline.vim', opt = true }

  -- Readline style insertion
  use 'tpope/vim-rsi'

  -- Format SQL
  use 'vim-scripts/SQLUtilities'

  -- Surround - sa%" sa$' saE" srb" sr"' sd"
  --use 'machakann/vim-sandwich'
  use { 'kylechui/nvim-surround', config = function() require("nvim-surround").setup({}) end }

  -- Spider cursor movement
  use { "chrisgrieser/nvim-spider" }

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

  use "almo7aya/openingh.nvim"

  -- Markdown preview
  use { 'davinche/godown-vim', ft = {'markdown'} }

  -- Git
  use { 'tpope/vim-fugitive', config = function()
    -- vim.keymap.set("", "<leader>G", ":Ggrep <C-R><C-W> ':(exclude)*fake*'<CR>")
  end }

  use 'airblade/vim-gitgutter'

  -- Snippets
  use 'rafamadriz/friendly-snippets'
  use { 'L3MON4D3/LuaSnip', config = function() require("luasnip.loaders.from_vscode").lazy_load() end }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
