-- javascript.lua
return {
  mason = { 'typescript-language-server', 'prettier', 'eslint_d' },
  lsp = {
    ts_ls = {},
  },
  formatters = {
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescriptreact = { 'prettier' },
    html = { 'prettier' },
    css = { 'prettier' },
    scss = { 'prettier' },
  },
  linters = {
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    javascriptreact = { 'eslint_d' },
    typescriptreact = { 'eslint_d' },
  },
  formatter_options = {
    prettier = {
      args = { '--stdin-filepath', '$FILENAME', '--experimental-ternaries' },
      stdin = true,
    },
  },
}
