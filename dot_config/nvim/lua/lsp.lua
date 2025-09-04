-- vim: ts=2 sw=2
---@diagnostic disable: undefined-global, undefined-field

-- Enable native LSP servers
vim.lsp.enable({
  "clangd",
  "gopls",
  "helm_ls",
  "html",
  "jsonls",
  "lua_ls",
  "pylsp",
  "solargraph",
  "ts_ls",
  "yamlls",
})

vim.diagnostic.config({
  virtual_text = true,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local autocmd = vim.api.nvim_create_autocmd
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- TODO gq vs gw
    vim.bo[args.buf].formatprg = nil

    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    if client:supports_method('textDocument/documentHighlight') then
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
      local augroup = vim.api.nvim_create_augroup('lsp_go_format', { clear = false })

      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = augroup })

      autocmd({ 'BufWritePre' }, {
        group = augroup,
        pattern = { "*.go" },
        callback = function()
          local params = vim.lsp.util.make_range_params(nil, nil, 0, "utf-16")
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
return {}
