-- cpp.lua
-- Note: root_dir is handled by native.lua default config
-- This file only overrides cmd and capabilities

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
      -- root_dir is provided by native.lua default_configs.clangd
      -- which uses the Neovim 0.11 callback-style root_dir function
    },
  },
  formatters = {
    cpp = { 'clang-format' },
    c = { 'clang-format' },
  },
}
