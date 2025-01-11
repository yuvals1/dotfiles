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
        '--header-insertion=iwyu',
      },
      filetypes = { 'c', 'cc', 'cpp', 'objc', 'objcpp', 'cuda', 'cu', 'cuh' },
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
  linter_options = {
    ['cpplint'] = {
      args = {
        '--filter=-build/header_guard,-legal/copyright', -- Filter out specific warnings
        '--counting=detailed',
        '--linelength=120',
        '--verbose=0', -- Only show errors (severity level 0)
      },
    },
  },
}
