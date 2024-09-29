local language_utils = require('plugins.languages.language_utils')
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    {
      'williamboman/mason-lspconfig.nvim',
      event = "VeryLazy",
      opts = {
        ensure_installed = vim.tbl_keys(configs.lsp_servers),
      },
    },
    {
      'neovim/nvim-lspconfig',
      event = {"BufReadPre", "BufNewFile"},
      config = function()
        local lspconfig = require('lspconfig')
        for server, config in pairs(configs.lsp_servers) do
          lspconfig[server].setup(config)
        end
      end,
    },
  }
end

return M
