-- yaml.lua
return {
  mason = { 'yaml-language-server', 'yamllint', 'prettier' },
  lsp = {
    yamlls = {},
  },
  formatters = {
    yaml = { 'prettier' },
  },
  linters = {
    yaml = { 'yamllint' },
  },
  formatter_options = {
    prettier = {
      args = { '--stdin-filepath', '$FILENAME' },
      stdin = true,
    },
  },
}
