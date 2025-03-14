-- vim: ts=2 sw=2
-- https://github.com/nanotee/nvim-lua-guide
---@diagnostic disable: undefined-global, undefined-field

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    if client:supports_method('textDocument/documentHighlight') then
      local autocmd = vim.api.nvim_create_autocmd
      local augroup = vim.api.nvim_create_augroup('lsp_highlight', { clear = false })

      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = augroup })

      autocmd({ 'CursorHold' }, {
        group = augroup,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })

      autocmd({ 'CursorMoved' }, {
        group = augroup,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- if client:supports_method('textDocument/formatting') then
    --   vim.api.nvim_create_autocmd('BufWritePre', {
    --
    --     buffer = args.buf,
    --     callback = function()
    --       vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
    --     end,
    --   })
    -- end

    if client:supports_method('textDocument/codeAction') then
      local autocmd = vim.api.nvim_create_autocmd
      local augroup = vim.api.nvim_create_augroup('lsp_go_format', { clear = false })

      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = augroup })

      autocmd({ 'BufWritePre' }, {
        group = augroup,
        pattern = { "*.go" },
        callback = function()
          local params = vim.lsp.util.make_range_params()
          params.context = { only = { "source.organizeImports" } }
          -- buf_request_sync defaults to a 1000ms timeout. Depending on your
          -- machine and codebase, you may want longer. Add an additional
          -- argument after params if you find that you have to write the file
          -- twice for changes to be saved.
          -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
          for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end
          vim.lsp.buf.format({ async = false })
        end,
      })
    end

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', { buffer = args.buf })
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { buffer = args.buf })
    vim.keymap.set('n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<cr>', { buffer = args.buf })
    vim.keymap.set('n', ']g', '<cmd>lua vim.diagnostic.goto_next()<cr>', { buffer = args.buf })
    vim.keymap.set('n', '[g', '<cmd>lua vim.diagnostic.goto_prev()<cr>', { buffer = args.buf })

    -- 0.11 keybindings
    -- gri
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', { buffer = args.buf })
    -- grr
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', { buffer = args.buf })
    -- grn
    vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', { buffer = args.buf })
    -- gra
    vim.keymap.set('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<cr>', { buffer = args.buf })

    vim.keymap.set('n', 'gO', '<cmd>lua vim.lsp.buf.document_symbol()<cr>', { buffer = args.buf })
    vim.keymap.set('i', '<C-S>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', { buffer = args.buf })

    -- vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', { buffer = args.buf })
    -- vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', { buffer = args.buf })
    -- vim.keymap.set('n', '<F3>', '<cmd>lua vim.lsp.buf.format()<cr>', { buffer = args.buf })
    -- vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { buffer = args.buf })
  end,
})

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
        enable = true, -- false will disable the whole extension
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

  -- Autocompletion
  {
    'saghen/blink.cmp',
    -- use a release tag to download pre-built binaries
    version = '*',
    lazy = false,

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept, C-n/C-p for up/down)
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys for up/down)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- keymap = { preset = 'default' },
      keymap = {
        preset = "super-tab",
        -- preset = "enter",
        -- ["<S-Tab>"] = { "select_prev", "fallback" },
        -- ["<Tab>"] = { "select_next", "fallback" },
        -- ['<A-y>'] = require('minuet').make_blink_map(),
        ['<CR>'] = { 'accept', 'fallback' },
      },
      cmdline = {
        sources = { "cmdline" },
        keymap = {
          ['<CR>'] = { 'accept', 'fallback' },
        }
      },
      completion = {
        ghost_text = { enabled = true },
        menu = {
          border = "rounded",
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = {
            border = "rounded",
          },
        },
      },

      appearance = {
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      sources = {
        default = { 'lsp', 'path', 'buffer', 'snippets' },

        -- default = { 'lsp', 'path', 'buffer', 'snippets', 'minuet' },
        -- providers = {
        --   minuet = {
        --     name = 'minuet',
        --     module = 'minuet.blink',
        --     score_offset = 100,
        --   },
        -- },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
        max_typos = function(keyword) return math.floor(#keyword / 2) end,
      }
    },
    opts_extend = { "sources.default" }
  },

  -- Languageservers
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },

    -- example using `opts` for defining servers
    opts = {
      servers = {
        clangd = {},
        gopls = {},
        helm_ls = {},
        jsonls = {},
        lua_ls = {},
        solargraph = {},
        yamlls = {},
      }
    },
    config = function(_, opts)
      local lspconfig = require('lspconfig')
      for server, config in pairs(opts.servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  },

  -- LLM
  {
    'github/copilot.vim',
    ft = function()
      if os.getenv("COPILOT_DISABLE") ~= nil then
        return { 'ruby', 'go', 'js', 'sh', 'lua', 'vim', 'yaml', 'gitcommit', 'markdown' }
      end
      return {}
    end
  },

  -- {
  --   "olimorris/codecompanion.nvim",
  --   config = true,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   -- cond = function()
  --   --   return os.getenv("GEMINI_API_KEY") ~= "" and os.getenv("GEMINI_API_KEY") ~= nil
  --   -- end,
  --   opts = {
  --     adapters = {
  --       gemini = function()
  --         return require("codecompanion.adapters").extend("gemini", {
  --           env = {
  --             api_key = function()
  --               return os.getenv("GEMINI_API_KEY")
  --             end
  --           },
  --         })
  --       end,
  --       llama3 = function()
  --         return require("codecompanion.adapters").extend("ollama", {
  --           name = "llama3",
  --           schema = {
  --             model = { default = "llama3:latest", },
  --             num_ctx = { default = 16384, },
  --             num_predict = { default = -1, },
  --           },
  --         })
  --       end,
  --     },
  --     strategies = {
  --       chat = {
  --         adapter = "llama3",
  --       },
  --       inline = {
  --         adapter = "llama3",
  --       },
  --     },
  --   },
  -- },

  -- {
  --   'milanglacier/minuet-ai.nvim',
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   config = function()
  --     require('minuet').setup {
  --       --provider = "gemini",
  --       provider = "openai_compat",
  --       blink = {
  --         enable_auto_complete = true,
  --       },
  --       provider_options = {
  --         gemini = {
  --           model = 'gemini-2.0-flash',
  --           stream = true,
  --           api_key = function()
  --             return os.getenv("GEMINI_API_KEY")
  --           end
  --         },
  --         openai_compat = {
  --           name = "ollama",
  --           api_key = "TERM",
  --           model = 'qwen2.5-coder:7b',
  --           end_point = "http://localhost:11434/v1/chat/completions",
  --         },
  --       }
  --     }
  --   end
  -- },

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
        ['n'] = ' ',
        ['i'] = '󰙏 ',
        ['c'] = ' ',
        ['v'] = '󰸿 ',
        ['V'] = '󰸽 ',
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
          lualine_y = { 'searchcount', 'progress' },
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
  -- { 'drewtempelmeyer/palenight.vim' },
  -- { 'embark-theme/vim' },
  -- { 'iCyMind/NeoSolarized' },
  -- { 'jonathanfilip/vim-lucius' },
  -- { 'noahfrederick/vim-hemisu' },
  -- { 'sainnhe/sonokai' },
  -- { 'sontungexpt/witch' },
  -- { 'tomasr/molokai' },
  { 'chriskempson/base16-vim' },
  { 'TroyFletcher/vim-colors-synthwave' },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    -- on_colors = function(c)
    --   c.border = c.blue0
    -- end,
    config = function()
      vim.cmd [[colorscheme tokyonight]]
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
      -- vim.cmd [[colorscheme dracula]]
    end
  },

  -- Tmux integration
  -- { 'edkolev/tmuxline.vim', lazy = true },

  -- Readline style insertion
  { 'tpope/vim-rsi' },

  -- Spider cursor movement
  { "chrisgrieser/nvim-spider" },


  -- Surround - sa%" sa$' saE" srb" sr"' sd"
  {
    'echasnovski/mini.nvim',
    version = false,
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
      { "<leader>ge",      function() Snacks.explorer.reveal() end,                                desc = "Reveal" },
      -- luacheck: push ignore 113
      { "<leader>f",       function() Snacks.picker.grep() end,                                    desc = "Grep" },
      { "<leader>g",       function() Snacks.picker.git_grep() end,                                desc = "Git Grep" },
      { "<leader>G",       function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word", mode = { "n", "x" } },
      { "<leader>b",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      { "<leader>t",       function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
      { "<leader>s",       function() Snacks.picker.icons() end,                                   desc = "Icons" },
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
      -- { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      -- { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
      -- { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>e",       function() Snacks.explorer() end,                                       desc = "File Explorer" },
      -- find
      -- { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "Find Files" },
      { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
      { "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
      { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
      -- git
      { "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "Git Branches" },
      { "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "Git Log" },
      { "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "Git Log Line" },
      { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status" },
      { "<leader>gS",      function() Snacks.picker.git_stash() end,                               desc = "Git Stash" },
      { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
      { "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "Git Log File" },
      -- Grep
      { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
      { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
      -- { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>gw",      function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word", mode = { "n", "x" } },
      -- search
      { '<leader>s"',      function() Snacks.picker.registers() end,                               desc = "Registers" },
      { '<leader>s/',      function() Snacks.picker.search_history() end,                          desc = "Search History" },
      { "<leader>sa",      function() Snacks.picker.autocmds() end,                                desc = "Autocmds" },
      { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
      { "<leader>sc",      function() Snacks.picker.command_history() end,                         desc = "Command History" },
      { "<leader>sC",      function() Snacks.picker.commands() end,                                desc = "Commands" },
      { "<leader>sd",      function() Snacks.picker.diagnostics() end,                             desc = "Diagnostics" },
      { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics" },
      { "<leader>sh",      function() Snacks.picker.help() end,                                    desc = "Help Pages" },
      { "<leader>sH",      function() Snacks.picker.highlights() end,                              desc = "Highlights" },
      { "<leader>si",      function() Snacks.picker.icons() end,                                   desc = "Icons" },
      { "<leader>sj",      function() Snacks.picker.jumps() end,                                   desc = "Jumps" },
      { "<leader>sk",      function() Snacks.picker.keymaps() end,                                 desc = "Keymaps" },
      { "<leader>sl",      function() Snacks.picker.loclist() end,                                 desc = "Location List" },
      { "<leader>sm",      function() Snacks.picker.marks() end,                                   desc = "Marks" },
      { "<leader>sM",      function() Snacks.picker.man() end,                                     desc = "Man Pages" },
      { "<leader>sp",      function() Snacks.picker.lazy() end,                                    desc = "Search for Plugin Spec" },
      { "<leader>sq",      function() Snacks.picker.qflist() end,                                  desc = "Quickfix List" },
      { "<leader>sR",      function() Snacks.picker.resume() end,                                  desc = "Resume" },
      { "<leader>su",      function() Snacks.picker.undo() end,                                    desc = "Undo History" },
      { "<leader>uC",      function() Snacks.picker.colorschemes() end,                            desc = "Colorschemes" },
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
  { 'manno/file-line' },

  { "almo7aya/openingh.nvim" },

  -- Format SQL
  { 'vim-scripts/SQLUtilities',  ft = { 'sql' } },

  { 'zerowidth/vim-copy-as-rtf', cond = function() return vim.fn.has('mac') end },

  -- Markdown preview
  { 'davinche/godown-vim',       ft = { 'markdown' } },

  -- Git
  {
    'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end,
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      vim.keymap.set("n", "<leader>v",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd(
              "DiffviewClose")
          end
        end)
    end
  },
  {
    "FabijanZulj/blame.nvim",
    config = function()
      require("blame").setup()
    end
  },

})
