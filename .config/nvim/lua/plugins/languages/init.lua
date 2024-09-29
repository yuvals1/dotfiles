-- plugins/languages/init.lua
local M = {}

-- List of language-specific configuration files
local languages = {
  require('plugins.languages.lua'),
  require('plugins.languages.python'),
  require('plugins.languages.markdown'),
}

-- Aggregated configurations
local mason_packages = {}
local lsp_servers = {}
local formatters = {}
local linters = {}

for _, lang in ipairs(languages) do
  -- Collect Mason packages
  if lang.mason then
    vim.list_extend(mason_packages, lang.mason)
  end
  -- Collect LSP servers
  if lang.lsp then
    for server, config in pairs(lang.lsp) do
      lsp_servers[server] = config
    end
  end
  -- Collect formatters
  if lang.formatters then
    for ft, formatter in pairs(lang.formatters) do
      formatters[ft] = formatter
    end
  end
  -- Collect linters
  if lang.linters then
    for ft, linter in pairs(lang.linters) do
      linters[ft] = linter
    end
  end
end

M.plugins = {
  -- Mason setup
  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = mason_packages,
    },
  },
  -- Mason LSPConfig setup
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = vim.tbl_keys(lsp_servers),
    },
  },
  -- LSPConfig setup
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')
      for server, config in pairs(lsp_servers) do
        lspconfig[server].setup(config)
      end
    end,
  },
  -- Conform setup
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = formatters,
    },
  },
  -- Nvim-lint setup
  {
    'mfussenegger/nvim-lint',
    config = function()
      require('lint').linters_by_ft = linters
    end,
  },
}

return M.plugins

