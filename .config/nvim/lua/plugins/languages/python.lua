return {
  mason = { 'pyright', 'black', 'isort', 'flake8' },
  lsp = {
    pyright = {},
  },
  formatters = {
    python = { 'black', 'isort' },
  },
  linters = {
    python = { 'flake8' },
  },
}
