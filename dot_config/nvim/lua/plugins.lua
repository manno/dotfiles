-- vim: ts=2 sw=2
-- https://github.com/nanotee/nvim-lua-guide

local silentOpt = { silent = true }
local allOpt = { noremap = true, silent = true, nowait = true }

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup({
  { 'wbthomason/packer.nvim' },

  -- Parsers, replaces vim-polyglot
  -- TSInstall ft
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      -- ensure_installed = "all",
      -- ignore_install = { "phpdoc" },
      ensure_installed = { 'bash', 'html', 'lua', 'markdown', 'vim', 'vimdoc', 'go', 'yaml' },
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
    },
    config = function(_, opts)
      require 'nvim-treesitter.configs'.setup(opts)
    end
  },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'nvim-treesitter/nvim-treesitter-context' },

  -- Languageservers
  -- run :CocConfig to add language servers, e.g.
  -- run :CocCommand go.install.gopls
  --   go get -u golang.org/x/tools/...
  --   https://github.com/josa42/coc-go#example-configuration
  --   https://github.com/neoclide/coc.nvim/blob/master/data/schema.json
  -- run :CocUpdate
  -- run :CocInstall ft
  -- CocInstall coc-diagnostic
  {
    'neoclide/coc.nvim',
    branch = 'release',
    build = ':CocInstall coc-go',
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
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim', version = '0.1.6',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim',
      build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
      { "davvid/telescope-git-grep.nvim", version = "v1.0.2" },
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
  },

  {'nvim-telescope/telescope-symbols.nvim'},

  -- Status line
  {
    'romgrk/barbar.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'lewis6991/gitsigns.nvim' },
    config = function()
      vim.keymap.set('', '<leader>w', ':BufferWipeout<cr>')
      vim.keymap.set('', '<C-n>', ':BufferNext<cr>')
      vim.keymap.set('', '<C-p>', ':BufferPrevious<cr>')
    end
  },

  {
    'hoob3rt/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
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
    end
  },

  -- NerdCommenter
  {
    'scrooloose/nerdcommenter',
    config = function()
      vim.g.NERDSpaceDelims = 1
    end
  },

  -- Autocompletion
  { 'github/copilot.vim', ft = {'ruby', 'go', 'js', 'sh', 'lua', 'vim', 'yaml'} },

  -- Colorschemes
  { 'jonathanfilip/vim-lucius', lazy = true },
  { 'tomasr/molokai', lazy = true },
  { 'noahfrederick/vim-hemisu', lazy = true },
  { 'endel/vim-github-colorscheme', lazy = true },
  --'chriskempson/vim-tomorrow-theme'
  --'iCyMind/NeoSolarized'
  { 'TroyFletcher/vim-colors-synthwave', lazy = true },
  --'drewtempelmeyer/palenight.vim'
  --{'embark-theme/vim', { name = 'embark' }}
  --'sainnhe/sonokai'
  {
    'folke/tokyonight.nvim',
    config = function()
      -- vim.cmd[[colorscheme tokyonight]]
    end
  },

  {
    'sontungexpt/witch',
    config = function(_, opts)
      --require("witch").setup(opts)
      --vim.cmd[[colorscheme witch]]
    end
  },

  {
    'binhtran432k/dracula.nvim',
    config = function(_, opts)
      require("dracula").setup(opts)
      vim.cmd[[colorscheme dracula]]
    end
  },

  -- Tmux integration
  { 'edkolev/tmuxline.vim', lazy = true },

  -- Readline style insertion
  {'tpope/vim-rsi'},

  -- Format SQL
  {'vim-scripts/SQLUtilities'},

  -- Surround - sa%" sa$' saE" srb" sr"' sd"
  --'machakann/vim-sandwich'
  {
    'kylechui/nvim-surround',
    config = function() require("nvim-surround").setup({}) end
  },

  -- Spider cursor movement
  { "chrisgrieser/nvim-spider" },

  -- Vim ruby
  { 'tpope/vim-bundler', ft = {'ruby'} },
  { 'tpope/vim-rake', ft = {'ruby'} },
  { 'tpope/vim-rails', ft = {'ruby'} },
  {
    'janko-m/vim-test',
    config = function()
      vim.g['test#strategy'] = "neovim"
      vim.keymap.set("n", "<F3>", ":TestFile<CR>")
    end
  },

  -- Open files at line
  {'manno/file-line'},

  {
    'zerowidth/vim-copy-as-rtf',
    cond = function() return vim.fn.has('mac') end
  },

  {"almo7aya/openingh.nvim"},

  -- Markdown preview
  { 'davinche/godown-vim', ft = {'markdown'} },

  -- Git
  {
    'tpope/vim-fugitive',
    config = function()
      -- vim.keymap.set("", "<leader>G", ":Ggrep <C-R><C-W> ':(exclude)*fake*'<CR>")
    end
  },

  {'airblade/vim-gitgutter'},

  -- Snippets
  {'rafamadriz/friendly-snippets'},
  {
    'L3MON4D3/LuaSnip',
    config = function() require("luasnip.loaders.from_vscode").lazy_load() end
  },

})
