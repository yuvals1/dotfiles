-- linux_arm.lua
-- Narrow, low-friction profile for ARM Ubuntu
-- Keeps only Lua to avoid Mason/platform issues.
return {
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

