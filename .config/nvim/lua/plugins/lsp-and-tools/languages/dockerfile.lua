-- dockerfile.lua
return {
  mason = { 'dockerfile-language-server', 'hadolint' },
  lsp = {
    dockerls = {}, -- Dockerfile language server configuration
  },
  formatters = {
    -- Dockerfile formatting is typically handled by the LSP
    dockerfile = {},
  },
  linters = {
    dockerfile = { 'hadolint' },
  },
  linter_options = {
    hadolint = {
      -- You can customize hadolint options here if needed
      -- args = { '--format=json' },
    },
  },
}
