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
        return vim.fs.root(fname, {'compile_commands.json', 'compile_flags.txt', 'Makefile', '.git'})
      end,
    },
  },
  formatters = {
    cpp = { 'clang-format' },
  },
}
