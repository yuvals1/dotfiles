-- init.lua
local M = {}
local languages = {
  require 'plugins.lsp-and-tools.languages.lua',
  require 'plugins.lsp-and-tools.languages.python',
  require 'plugins.lsp-and-tools.languages.markdown',
  require 'plugins.lsp-and-tools.languages.json',
  require 'plugins.lsp-and-tools.languages.bash',
  require 'plugins.lsp-and-tools.languages.xml',
  require 'plugins.lsp-and-tools.languages.yaml',
  require 'plugins.lsp-and-tools.languages.toml',
  require 'plugins.lsp-and-tools.languages.javascript',
  require 'plugins.lsp-and-tools.languages.ruby',
}

-- Require the highlight module
local highlight = require 'plugins.lsp-and-tools.highlight'

-- Set a lower updatetime
vim.opt.updatetime = 500

-- brewfile is a ruby file
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { 'Brewfile' },
  callback = function()
    vim.bo.filetype = 'ruby'
  end,
})
-- Function to set up highlighting for each language server
local function setup_highlighting(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    highlight.setup { buf = bufnr }
  end
end

M.plugins = {
  require('plugins.lsp-and-tools.mason').setup(languages),
  require('plugins.lsp-and-tools.mason-tool-installer').setup(languages),
  require('plugins.lsp-and-tools.lspconfig').setup(languages, setup_highlighting),
  require('plugins.lsp-and-tools.conform').setup(languages),
  require('plugins.lsp-and-tools.lint').setup(languages),
  require('plugins.lsp-and-tools.keymaps').setup(),
}

return M.plugins