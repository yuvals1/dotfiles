-- linux_arm.lua
-- Targeted profile for ARM Ubuntu with Lua, Python, JavaScript, Svelte, and C++ tooling.
return {
  require 'plugins.lsp-and-tools.languages.python',
  require 'plugins.lsp-and-tools.languages.javascript',
  require 'plugins.lsp-and-tools.languages.svelte',
  -- Custom C++ config for ARM - use system clangd instead of Mason
  -- NOTE: We do NOT require cpp.lua here since it would add clangd to Mason tools
  {
    mason = {}, -- Don't install any C++ tools via Mason on ARM
    lsp = {
      clangd = {
        cmd = {
          '/usr/bin/clangd', -- Use system clangd explicitly
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
  },
  {
    mason = { 'lua-language-server', 'stylua' },
    lsp = {
      lua_ls = {
        settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
      },
    },
    formatters = { lua = { 'stylua' } },
  },
}
