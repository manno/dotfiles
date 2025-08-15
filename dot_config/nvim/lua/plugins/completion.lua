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
      keymap = {
        preset = "super-tab",
        -- preset = "enter",
        -- ["<S-Tab>"] = { "select_prev", "fallback" },
        -- ["<Tab>"] = { "select_next", "fallback" },
        ['<CR>'] = { 'accept', 'fallback' },
      },
      cmdline = {
        sources = { "cmdline" },
        keymap = {
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
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
      },

      fuzzy = {
        implementation = "prefer_rust_with_warning",
        max_typos = function(keyword) return math.floor(#keyword / 9) end,
      }
    },

    opts_extend = { "sources.default" }
  },
}
