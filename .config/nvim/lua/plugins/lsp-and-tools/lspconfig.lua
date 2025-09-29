local language_utils = require 'plugins.lsp-and-tools.language_utils'
local highlight = require 'plugins.lsp-and-tools.highlight'
local M = {}

function M.setup(languages, setup_highlighting)
  local configs = language_utils.collect_configurations(languages)
  return {
    {
      'williamboman/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      opts = {
        -- Don't automatically install anything - let mason-tool-installer handle it
        ensure_installed = {},
        automatic_installation = false,
      },
    },
    {
      'neovim/nvim-lspconfig',
      dependencies = { 'williamboman/mason-lspconfig.nvim' },
      event = { 'BufReadPre', 'BufNewFile' },
      config = function()
        local server_names = {}
        for server, config in pairs(configs.lsp_servers) do
          local original_on_attach = config.on_attach
          config.on_attach = function(client, bufnr)
            if original_on_attach then
              original_on_attach(client, bufnr)
            end
            setup_highlighting(client, bufnr)
          end
          vim.lsp.config[server] = config
          table.insert(server_names, server)
        end
        if #server_names > 0 then
          vim.lsp.enable(server_names)
        end
      end,
    },
  }
end

return M
