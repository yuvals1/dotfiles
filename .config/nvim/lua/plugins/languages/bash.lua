-- bash.lua
return {
  mason = { 'bash-language-server', 'shellcheck', 'shfmt' },
  lsp = {
    bashls = {},
  },
  formatters = {
    sh = { 'shfmt' },
  },
  linters = {
    sh = { 'shellcheck' },
  },
}
