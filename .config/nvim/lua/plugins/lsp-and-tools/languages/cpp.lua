-- cpp.lua
return {
  mason = { 'clangd', 'clang-format' },
  lsp = {
    clangd = {
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--completion-style=detailed',
        '--header-insertion=iwyu',
      },
      capabilities = {
        offsetEncoding = { 'utf-16' },
      },
      root_dir = function(fname)
        return require('lspconfig.util').root_pattern('compile_commands.json', 'compile_flags.txt', 'Makefile', '.git')(fname)
      end,
    },
  },
  formatters = {
    cpp = { 'clang-format' },
  },
}
