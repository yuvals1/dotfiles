local M = {}

local languages = {
  require('plugins.languages.lua'),
  require('plugins.languages.python'),
  require('plugins.languages.markdown'),
}

M.plugins = {
  require('plugins.languages.mason').setup(languages),
  require('plugins.languages.lspconfig').setup(languages),
  require('plugins.languages.conform').setup(languages),
  require('plugins.languages.lint').setup(languages),
}

return M.plugins
