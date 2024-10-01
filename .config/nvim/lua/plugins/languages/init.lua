-- init.lua
local M = {}
local languages = {
  require 'plugins.languages.lua',
  require 'plugins.languages.python',
  require 'plugins.languages.markdown',
  require 'plugins.languages.json',
  require 'plugins.languages.bash',
  require 'plugins.languages.xml',
  require 'plugins.languages.yaml',
  require 'plugins.languages.toml',
  require 'plugins.languages.javascript',
}

-- Require the highlight module
local highlight = require 'plugins.languages.highlight'

-- Set a lower updatetime
vim.opt.updatetime = 500

-- Function to set up highlighting for each language server
local function setup_highlighting(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    highlight.setup { buf = bufnr }
  end
end

M.plugins = {
  require('plugins.languages.mason').setup(languages),
  require('plugins.languages.mason-tool-installer').setup(languages),
  require('plugins.languages.lspconfig').setup(languages, setup_highlighting),
  require('plugins.languages.conform').setup(languages),
  require('plugins.languages.lint').setup(languages),
}

return M.plugins
