-- vim: ts=2 sw=2
---@diagnostic disable: undefined-global, undefined-field

return {
  -- Autocompletion
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  {
    'saghen/blink.cmp',
    -- use a release tag to download pre-built binaries
    version = '*',
    lazy = false,
    optional = true,
    dependencies = { "fang2hou/blink-copilot" },

    ---@module 'blink.cmp'
    opts = {
      keymap = {
        preset = "super-tab",
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
        default = { 'lsp', 'path', 'buffer', 'copilot', 'snippets' },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
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
}
