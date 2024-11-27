-- lua.lua
return {
  mason = { 'lua-language-server', 'stylua' },
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
    -- lua = { 'luacheck' },
  },
  linter_options = {
    luacheck = {
      args = { '--globals', 'vim' },
    },
  },
}
