local M = {}

M.setup = function()
  require('mason').setup()

  local ensure_installed = vim.tbl_keys(require('plugins.lsp.servers').servers or {})
  vim.list_extend(ensure_installed, {
    'stylua',
  })
  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  require('mason-lspconfig').setup {
    handlers = {
      function(server_name)
        local server = require('plugins.lsp.servers').servers[server_name] or {}
        require('lspconfig')[server_name].setup(server)
      end,
    },
  }
end

return M
