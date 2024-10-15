-- go.lua
return {
  mason = { 'gopls', 'gofumpt', 'golines', 'golangci-lint' },
  lsp = {
    gopls = {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
            shadow = true,
          },
          staticcheck = true,
        },
      },
    },
  },
  formatters = {
    go = { 'gofumpt', 'golines' },
  },
  linters = {
    go = { 'golangcilint' },
  },
}
