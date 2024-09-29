-- plugins/languages/markdown.lua
return {
  mason = { 'markdownlint', 'prettier' },
  formatters = {
    markdown = { 'prettier' },
  },
  linters = {
    markdown = { 'markdownlint' },
  },
}

