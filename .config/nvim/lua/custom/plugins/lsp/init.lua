local M = {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp',
  },
}

function M.config()
  require('custom.plugins.lsp.keymaps').setup()
  require('custom.plugins.lsp.servers').setup()
  require('custom.plugins.lsp.mason_setup').setup()
end

return M
