-- plugins/languages/python.lua
return {
  mason = { 'pyright', 'black', 'flake8' },
  lsp = {
    pyright = {},
  },
  formatters = {
    python = { 'black' },
  },
  linters = {
    python = { 'flake8' },
  },
}

