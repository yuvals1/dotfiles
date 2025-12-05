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
        -- root_dir uses Neovim 0.11 callback style: function(bufnr, on_dir)
        root_dir = function(bufnr, on_dir)
          local markers = { 'compile_commands.json', 'compile_flags.txt', 'Makefile', '.git' }
          local root = vim.fs.root(bufnr, markers)
          if root then
            on_dir(root)
          else
            -- Fallback to buffer directory
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname and bufname ~= '' then
              on_dir(vim.fs.dirname(bufname))
            else
              on_dir(vim.uv.cwd())
            end
          end
        end,
      },
    },
    formatters = {
      cpp = { 'clang-format' },
      c = { 'clang-format' },
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
