vim.g.go_def_mapping_enabled = 0
vim.opt_local.formatoptions:append("cqrn1")

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    -- Check if LSP is attached
    if vim.lsp.get_clients({ bufnr = 0 })[1] == nil then
      vim.notify("No LSP client attached", vim.log.levels.WARN)
      return
    end

    -- Organize imports
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    if not result then
      vim.notify("Failed to organize imports", vim.log.levels.WARN)
      return
    end

    for cid, res in pairs(result) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end

    -- Format the buffer
    local format_success, format_err = pcall(vim.lsp.buf.format, { async = false })
    if not format_success then
      vim.notify("Format failed: " .. tostring(format_err), vim.log.levels.WARN)
    end
  end,
})
