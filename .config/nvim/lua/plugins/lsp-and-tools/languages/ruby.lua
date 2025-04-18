-- languages/ruby.lua
return {
  mason = { 'solargraph' },
  lsp = {
    solargraph = {
      filetypes = { 'ruby', 'rakefile', 'erb', 'Brewfile' },
      settings = {
        solargraph = {
          diagnostics = true,
          completion = true,
        },
      },
    },
  },
  formatters = {
    ruby = { 'rubocop' },
    Brewfile = { 'rubocop' },
  },
  linters = {
    ruby = { 'rubocop' },
    Brewfile = { 'rubocop' },
  },
  formatter_options = {
    rubocop = {
      command = 'rubocop',
      args = { '--auto-correct', '-f', 'quiet', '--stdin', '$FILENAME' },
      stdin = true,
    },
  },
}
