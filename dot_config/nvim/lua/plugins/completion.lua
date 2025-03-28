-- vim: ts=2 sw=2
---@diagnostic disable: undefined-global, undefined-field

return {
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

}
