-- lua.lua
return {
  mason = { 'lua-language-server', 'stylua', 'luacheck' }, -- Include all tools here
  lsp = {
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = { globals = { 'vim' } },
        },
      },
    },
  },
  formatters = {
    lua = { 'stylua' },
  },
  linters = {
    lua = { 'luacheck' },
  },
}
