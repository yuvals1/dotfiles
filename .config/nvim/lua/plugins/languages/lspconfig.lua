local language_utils = require 'plugins.languages.language_utils'
local highlight = require 'plugins.languages.highlight'
local M = {}

function M.setup(languages, setup_highlighting)
  local configs = language_utils.collect_configurations(languages)
  return {
    {
      'williamboman/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      opts = {
        ensure_installed = vim.tbl_keys(configs.lsp_servers),
      },
    },
    {
      'neovim/nvim-lspconfig',
      dependencies = { 'williamboman/mason-lspconfig.nvim' },
      event = { 'BufReadPre', 'BufNewFile' },
      config = function()
        local lspconfig = require 'lspconfig'
        for server, config in pairs(configs.lsp_servers) do
          local original_on_attach = config.on_attach
          config.on_attach = function(client, bufnr)
            if original_on_attach then
              original_on_attach(client, bufnr)
            end
            setup_highlighting(client, bufnr)
          end
          lspconfig[server].setup(config)
        end
      end,
    },
  }
end

return M
