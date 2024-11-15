-- cpp.lua
return {
  mason = { 'clangd', 'clang-format', 'cpplint' },
  lsp = {
    clangd = {
      cmd = {
        'clangd',
        '--background-index',
        '--pch-storage=memory',
        '--clang-tidy',
        '--suggest-missing-includes',
        '--header-insertion=iwyu',
        '--cuda-include-path=/usr/local/cuda/include', -- For CUDA support
      },
      filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'cu', 'cuh' },
    },
  },
  formatters = {
    cpp = { 'clang-format' },
    c = { 'clang-format' },
    cuda = { 'clang-format' },
  },
  linters = {
    cpp = { 'cpplint' },
    c = { 'cpplint' },
    cuda = { 'cpplint' },
  },
  formatter_options = {
    ['clang-format'] = {
      args = { '--style=file' },
    },
  },
}
