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
      keymap = {
        preset = "super-tab",
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
        nerd_font_variant = 'mono'
      },

      sources = {
        default = { 'lsp', 'path', 'buffer', 'snippets', 'minuet' },
        providers = {
          minuet = {
            name = 'minuet',
            module = 'minuet.blink',
            score_offset = 100,
          },
        },
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
    'milanglacier/minuet-ai.nvim',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('minuet').setup {
        blink = {
          enable_auto_complete = true,
        },
        provider = "openai_compat",
        provider_options = {
          openai_compat = {
            name = "ollama",
            api_key = "TERM",
            model = 'qwen2.5-coder:7b',
            end_point = "http://localhost:11434/v1/chat/completions",
          },
        }
        -- provider = "gemini",
        -- provider_options = {
          -- gemini = {
          --   model = 'gemini-2.0-flash',
          --   stream = true,
          --   api_key = function()
          --     return os.getenv("GEMINI_API_KEY")
          --   end
          -- },
        -- }
      }
    end
  },
}

