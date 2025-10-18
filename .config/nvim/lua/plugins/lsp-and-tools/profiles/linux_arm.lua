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
          if type(fname) == 'number' then
            fname = vim.api.nvim_buf_get_name(fname)
          end
          local markers = { 'compile_commands.json', 'compile_flags.txt', 'Makefile', '.git' }
          local dir
          if not fname or fname == '' then
            dir = vim.loop.cwd()
          else
            local stat = vim.uv.fs_stat(fname)
            if stat and stat.type == 'directory' then
              dir = fname
            else
              dir = vim.fs.dirname(fname)
            end
          end
          dir = dir or vim.loop.cwd()
          local match = vim.fs.find(markers, { path = dir, upward = true })[1]
          if match then
            return vim.fs.dirname(match)
          end
          return dir
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
