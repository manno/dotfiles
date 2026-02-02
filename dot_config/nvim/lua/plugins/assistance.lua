-- vim: ts=2 sw=2
---@diagnostic disable: undefined-global, undefined-field

return {

  {
    "olimorris/codecompanion.nvim",
    config = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>ca", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
    },
    -- cond = function()
    --   return os.getenv("GEMINI_API_KEY") ~= "" and os.getenv("GEMINI_API_KEY") ~= nil
    -- end,
    opts = {
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = function()
                  return os.getenv("GEMINI_API_KEY")
                end
              },
            })
          end,
          llama3 = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "llama3",
              schema = {
                model = { default = "llama3:latest", },
                num_ctx = { default = 16384, },
                num_predict = { default = -1, },
              },
            })
          end,
        },
      },
      display = {
        action_palette = {
          provider = "snacks",
          -- this hides my prompts, not the builtins?
          -- opts = {
          --   show_prompt_library_builtins = false,
          -- },
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
      },
      prompt_library = {
        markdown = {
          dirs = {
            "~/.config/nvim/prompts", -- Or absolute paths
          },
        },
      },
    },
  },

}
