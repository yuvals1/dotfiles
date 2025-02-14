-- languages/go.lua
return {
  mason = { 'gopls', 'gofumpt', 'golines', 'golangci-lint' },
  lsp = {
    gopls = {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
            shadow = true,
          },
          staticcheck = true,
          gofumpt = true,
          usePlaceholders = true,
          codelenses = {
            gc_details = true,
            regenerate_cgo = true,
            generate = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
          },
        },
      },
      -- Add on_attach to set buffer-local options
      on_attach = function(client, bufnr)
        -- Set indent settings for Go files
        vim.bo[bufnr].tabstop = 4
        vim.bo[bufnr].shiftwidth = 4
        vim.bo[bufnr].softtabstop = 4
        vim.bo[bufnr].expandtab = false -- Go uses tabs

        -- Optionally set other Go-specific settings
        vim.bo[bufnr].textwidth = 100
      end,
    },
  },
  formatters = {
    go = { 'gofumpt', 'golines' },
  },
  formatter_options = {
    gofumpt = {
      args = { '-s' }, -- Simplify code
    },
    golines = {
      args = {
        '--max-len=100',
        '--base-formatter=gofumpt',
        '--tab-width=4',
        '--no-reformat-tags',
        '--shorten-comments',
      },
    },
  },
  linters = {
    go = { 'golangcilint' },
  },
}
