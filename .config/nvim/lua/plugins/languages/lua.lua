-- lua.lua
return {
  mason = { 'lua-language-server', 'stylua', 'luacheck' },
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
