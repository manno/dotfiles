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
  vim.fn.getchar()
  os.exit(1)
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup({
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
        callback = function(event)
          -- <c-]> is overriden by ruby ftpplugin
          vim.keymap.set("n", "<c-]>", "<Plug>(coc-definition)", { silent = true, buffer = event.buf })
          vim.keymap.set("n", "gd", "<Plug>(coc-definition)", silentOpt)
        end
      })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'c,cpp,go,ruby,rust,typescript,vue',
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
  { 'towolf/vim-helm' },

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
      -- local get_mode = require('lualine.utils.mode').get_mode
      local icons = {
        ['n']      = ' ',
        ['i']      = '󰙏 ',
        ['c']      = ' ',
        ['v']      = '󰸿 ',
        ['V']      = '󰸽 ',
      }
      require("lualine").setup({
        options = {
          theme = 'auto',
          globalstatus = true,
        },
        sections = {
          lualine_a = {
            {
              'mode',
              icons_enabled = true,
              fmt = function(mode)
                local m = vim.api.nvim_get_mode().mode
                if icons[m] == nil then
                  return mode
                end
                return icons[m] .. mode
              end
            }
          },
          lualine_b = {
            {
              'windows',
              mode = 1,
            },
            'diff',
            'diagnostics',
          },
          lualine_c = {
            {
              'filename',
              file_status = true,
              newfile_status = true,
              path = 1,
              shorting_target = 30,
            }
          },
          lualine_y = {'searchcount', 'progress'},
        },
        inactive_winbar = {
          lualine_c = {
            {
              'filename',
              file_status = true,
              newfile_status = true,
              path = 1,
              shorting_target = 30,
            }
          },
        },
        winbar = {
          lualine_c = {
            {
              'filename',
              file_status = true,
              newfile_status = true,
              path = 1,
              shorting_target = 30,
        }
          },
        },
      })
    end
  },

  -- Colorschemes
  -- 'chriskempson/vim-tomorrow-theme'
  -- 'drewtempelmeyer/palenight.vim'
  -- 'iCyMind/NeoSolarized'
  -- 'sainnhe/sonokai'
  -- {'embark-theme/vim', { name = 'embark' }}
  -- { 'TroyFletcher/vim-colors-synthwave', lazy = true },
  -- { 'jonathanfilip/vim-lucius', lazy = true },
  -- { 'noahfrederick/vim-hemisu', lazy = true },
  -- { 'tomasr/molokai', lazy = true },
  -- { 'sontungexpt/witch', lazy = true },
  { 'endel/vim-github-colorscheme', lazy = true },
  {
    'folke/tokyonight.nvim',
    lazy = true,
    priority = 1000,
    -- on_colors = function(c)
    --   c.border = c.blue0
    -- end,
    config = function()
      -- vim.cmd[[colorscheme tokyonight]]
    end
  },
  {
    'binhtran432k/dracula.nvim',
    config = function(_, opts)
      require("dracula").setup({
        lualine_bold = true,
        on_highlights = function(hl, c)
          hl.VertSplit = { fg = c.cyan }
          hl.WinSeparator = { fg = c.cyan }
        end
      })
      vim.cmd[[colorscheme dracula]]
    end
  },

  -- Tmux integration
  -- { 'edkolev/tmuxline.vim', lazy = true },

  -- Autocompletion
  { 'github/copilot.vim', ft = {'ruby', 'go', 'js', 'sh', 'lua', 'vim', 'yaml'} },

  -- Readline style insertion
  {'tpope/vim-rsi'},

  -- Spider cursor movement
  { "chrisgrieser/nvim-spider" },


  -- Surround - sa%" sa$' saE" srb" sr"' sd"
  { 'echasnovski/mini.nvim', version = false,
    config = function()
      require('mini.surround').setup()
      require('mini.sessions').setup()
    end
        },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "keys", gap = 1, padding = 3 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = 1 },
          {
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = vim.fn.isdirectory(".git") == 1,
            cmd = "git status --short --branch --renames",
            ttl = 5 * 60,
            height = 5,
            padding = 1,
            indent = 3,
          },
          {
            pane = 2,
            {
              section = "terminal",
              cmd = "cat ~/.config/nvim/wall.txt; sleep .1",
              height = 17,
              padding = 0,
            },
            { icon = " ", title = "Projects", section = "projects", indent = 3, padding = { 1, 1 } },
            -- { section = "startup", padding = 1, align = "left" },
          },
        },
      },
      explorer = { enabled = true },
      picker = {
        enabled = true,
        formatters = {
          file = {
            truncate = 60,
          },
        },
      },
      bufdelete = { enabled = false },
    },
    keys = {
      { "<leader>ge", function() Snacks.explorer.reveal() end, desc = "Reveal" },
      -- luacheck: push ignore 113
      { "<leader>f", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>g", function() Snacks.picker.git_grep() end, desc = "Git Grep" },
      { "<leader>G", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
      { "<leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>t", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>s", function() Snacks.picker.icons() end, desc = "Icons" },
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      -- { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      -- { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      -- { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
      -- find
      -- { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      -- git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
      -- Grep
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      -- { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>gw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
      -- search
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
      -- LSP
      -- { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      -- { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      -- { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      -- { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      -- { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      -- { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      -- { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    },
  },

  -- Vim ruby
  -- { 'tpope/vim-bundler', ft = {'ruby'} },
  -- { 'tpope/vim-rake', ft = {'ruby'} },
  -- { 'tpope/vim-rails', ft = {'ruby'} },
  -- {
  --   ft = {'ruby', 'go'},
  --   'janko-m/vim-test',
  --   config = function()
  --     vim.g['test#strategy'] = "neovim"
  --     vim.keymap.set("n", "<F3>", ":TestFile<CR>")
  --   end
  -- },

  -- Open files at line
  {'manno/file-line'},

  {"almo7aya/openingh.nvim"},

  -- Format SQL
  {'vim-scripts/SQLUtilities', ft = {'sql'}},

  { 'zerowidth/vim-copy-as-rtf', cond = function() return vim.fn.has('mac') end },

  -- Markdown preview
  { 'davinche/godown-vim', ft = {'markdown'} },

  -- Git
  {
    'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end,
  },
  { "sindrets/diffview.nvim" },
  {
    "FabijanZulj/blame.nvim",
    config = function()
      require("blame").setup()
    end
  },

})
