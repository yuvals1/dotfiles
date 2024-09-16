local M = {}

M.setup = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  M.servers = {
    bashls = {
      settings = {
        filetypes = { 'sh', 'zsh' },
      },
    },
    jsonls = {},
    marksman = {},
    lemminx = {},
    yamlls = {},
    lua_ls = {
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    },
  }

  for server_name, server in pairs(M.servers) do
    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    require('lspconfig')[server_name].setup(server)
  end
end

return M
