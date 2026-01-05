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
        ["Git Commit Message (cbeams)"] = {
          strategy = "inline",
          description = "Generate a commit message for the current buffer",
          opts = {
            index = 11,
            short_name = "commit",
            placement = "replace",
          },
          prompts = {
            {
              role = "system",
              content = [[You are an experienced developer who writes clear, concise commit messages and follows the "cbeams" principles.
              - Use the imperative mood in the subject line
              - Clear body: Explains the problem, the solution, and key behaviors
              - Concise: Covers what and why without diving into implementation details
              - Wrapped at 72 characters
              ]],
            },
            {
              role = "user",
              content = function(context)
                local bufnr = context.bufnr
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local code = table.concat(lines, "\n")
                return string.format(
                  [[Write a short commit message, for other developers, that describes the following diff content:

                  ```%s
                  %s
                  ```

                  Return only the commit message, no explanations or markdown formatting.
                  ]],
                  context.filetype,
                  code
                )
              end,
              opts = {
                contains_code = true,
              },
            }
          },
        },
      },
    },
  },

}
