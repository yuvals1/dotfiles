-- linux_arm.lua
-- Lightweight profile for ARM Ubuntu with Lua and Python tooling.
return {
  require 'plugins.lsp-and-tools.languages.python',
  {
    mason = { 'lua-language-server', 'stylua' },
    lsp = {
      lua_ls = {
        settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
      },
    },
    formatters = { lua = { 'stylua' } },
  },
}
