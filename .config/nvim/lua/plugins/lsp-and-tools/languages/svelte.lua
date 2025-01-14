-- svelte.lua
return {
  -- Mason packages to install
  mason = {
    'svelte-language-server', -- LSP
  },

  -- LSP configuration
  lsp = {
    svelte = {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = vim.fn.has 'nvim-0.10' == 0 and { dynamicRegistration = true },
        },
      },
    },
  },

  -- Empty formatters configuration since we're not using formatters
  formatters = {},

  -- Empty linters configuration since we're focusing on LSP only
  linters = {},
}
