-- vim: ts=2 sw=2
-- https://github.com/nanotee/nvim-lua-guide
---@diagnostic disable: undefined-global, undefined-field

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
  {
    'nvim-treesitter/nvim-treesitter',
    commit = "42fc28ba918343ebfd5565147a42a26580579482",
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function(_, opts)
      require('nvim-treesitter').install { 'bash', 'html', 'lua', 'markdown', 'markdown_inline', 'vim', 'vimdoc', 'go', 'yaml' }
    end
  },

  { 'towolf/vim-helm' },

  -- Status line
  {
    'romgrk/barbar.nvim',
    commit = "53b5a2f34b68875898f0531032fbf090e3952ad7",
    dependencies = { 'nvim-tree/nvim-web-devicons', 'lewis6991/gitsigns.nvim' },
    event = "VeryLazy",
    keys = {
      { '<leader>w', '<cmd>BufferWipeout<cr>', desc = "Close Buffer" },
      { '<C-n>', '<cmd>BufferNext<cr>', desc = "Next Buffer" },
      { '<C-p>', '<cmd>BufferPrevious<cr>', desc = "Previous Buffer" },
    },
  },

  {
    'hoob3rt/lualine.nvim',
    commit = "c55af3b39cc50109aa75d445e38f2089b023e5df",
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
              mode = 0,
            },
            'diff',
            'diagnostics',
          },
          lualine_c = {
          },
          lualine_y = { 'searchcount', 'progress' },
        },

        inactive_winbar = {
          lualine_a = { 'filetype' },
          lualine_c = {
            {
              'filename',
              color = 'Search',
              file_status = true,
              newfile_status = true,
              path = 1,
              shorting_target = 60,
            }
          },
        },

        winbar = {
          lualine_a = { 'filetype' },
          lualine_c = {
            {
              'filename',
              color = 'CurSearch',
              file_status = true,
              newfile_status = true,
              path = 1,
              shorting_target = 60,
            },
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
    commit = "545d72cde6400835d895160ecb5853874fd5156d",
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
    commit = "d2a8fe71323c958bdf46e8e69c97016fa7f7d703",
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
    'nvim-mini/mini.nvim',
    commit = "a995fe9cd4193fb492b5df69175a351a74b3d36b",
    version = false,
    config = function()
      require('mini.surround').setup()
      require('mini.sessions').setup()
    end
  },

  {
    "folke/snacks.nvim",
    commit = "e6fd58c82f2f3fcddd3fe81703d47d6d48fc7b9f",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 10000,
      },
      dashboard = {
        enabled = true,
        sections = {
          {
            key = "T",
            icon = "💡",
            desc = "Show Tips",
            action = function() require("utils").open_in_float(vim.fn.stdpath("config") .. "/tips.md") end,
            padding = { 1, 0 }
          },
          {
            key = "K",
            icon = "⌨️",
            desc = "Show Keybindings",
            action = function() require("utils").open_in_float(vim.fn.stdpath("config") .. "/README.md", "## ⌨️ Key Bindings") end,
            padding = { 1, 0 }
          },
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
              height = 10,
              padding = 0,
            },
            { text = "v" .. tostring(vim.version()), align = "center", padding = { 0, 0 } },
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
          notification = {
            wrap = true,
          },
        },
      },
      styles = {
        notification = {
          wo = { wrap = true },
        }
      },
      bufdelete = { enabled = false },
    },
    keys = {
      -- luacheck: push ignore 113
      { "<leader>ge",      function() Snacks.explorer.reveal() end,                                desc = "Reveal" },
      { "<leader>sn",      function() Snacks.notifier.show_history() end,                          desc = "Notification History" },
      { "<leader>f",       function() Snacks.picker.grep() end,                                    desc = "Grep" },
      { "<leader>G",       function() Snacks.picker.git_grep() end,                                desc = "Git Grep" },
      { "<leader>g",       function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word", mode = { "n", "x" } },
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

  {
    "almo7aya/openingh.nvim",
    commit = "0f1a90e70edacf8caace89bb80acd7eddc6234a6",
    keys = {
      { "<leader>gh", "<cmd>OpenInGHRepo<cr>", desc = "Open Repo in GitHub" },
      { "<leader>gH", "<cmd>OpenInGHFile<cr>", desc = "Open File in GitHub" },
    },
  },

  -- Format SQL
  { 'vim-scripts/SQLUtilities',  ft = { 'sql' } , commit = "566184530da81aa05ae4ac4ba6cf5034292a9b89"},

  { 'zerowidth/vim-copy-as-rtf', cond = function() return vim.fn.has('mac') end , commit = "ad90899d8a4178319252dc24c2671b26dae520d7"},

  -- Markdown preview
  { 'davinche/godown-vim',       ft = { 'markdown' } },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    commit = "e3c18ddd27a853f85a6f513a864cf4f2982b9f26",
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- Git
  {
    'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end,
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>v",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Toggle Diff View"
      },
    },
  },
  {
    "FabijanZulj/blame.nvim",
    config = function()
      require("blame").setup()
    end
  },

  -- Dynamic completion backend selection via environment variable
  -- NVIM_COMPLETION=copilot|minuet|vanilla (default: vanilla)
  { import = "plugins/" .. (vim.env.NVIM_COMPLETION == "copilot" and "completion-copilot" or
                          vim.env.NVIM_COMPLETION == "minuet" and "completion-minuet" or
                          "completion") },

  -- Optional AI assistance via environment variable
  -- NVIM_ASSISTANCE=true to enable CodeCompanion chat interface
  vim.env.NVIM_ASSISTANCE == "true" and { import = "plugins/assistance" } or {},
  {
    'neovim/nvim-lspconfig',
    commit = "0203a9608d63eda57679b01e69f33a7b4c34b0d1",
    dependencies = { 'saghen/blink.cmp' },
  },

  -- Open files at line
  { 'manno/file-line.nvim' },

  {
    "manno/qrencode.nvim",
    opts = {
      ecl = "M",
      prefer_image = true,
    },
  },

})
