-- Force-stop LSP clients on exit so quitting never blocks on a slow server
-- shutdown (e.g. gopls mid-index on a large repo can stall :q for 10s+).
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('lsp-force-exit', { clear = true }),
  callback = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      client:stop(true) -- force: kill instead of waiting for graceful shutdown
    end
  end,
})
