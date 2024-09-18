return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      python = { 'isort', 'black' },
      toml = { 'taplo' },
      -- Add Makefile formatting
      make = { 'checkmake' },
      -- Add TypeScript and JavaScript formatting with Prettier
      typescript = { 'prettier' },
      javascript = { 'prettier' },
      typescriptreact = { 'prettier' },
      javascriptreact = { 'prettier' },
      json = { 'prettier' },
      html = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      markdown = { 'prettier' },
    },
    -- Add the new formatting rules here
    formatters = {
      stylua = {
        prepend_args = {
          '--column-width',
          '160',
          '--line-endings',
          'Unix',
          '--indent-type',
          'Spaces',
          '--indent-width',
          '2',
          '--quote-style',
          'AutoPreferSingle',
          '--call-parentheses',
          'None',
        },
      },
      -- Add checkmake configuration
      checkmake = {
        command = 'checkmake',
        args = { "--format='{line}:{col} {severity}: {message}'" },
        stdin = false,
      },
      -- Add Prettier configuration
      prettier = {
        command = 'prettier',
        args = {
          '--stdin-filepath',
          '$FILENAME',
          '--single-quote',
          '--trailing-comma',
          'es5',
          '--print-width',
          '100',
        },
        stdin = true,
      },
    },
  },
}
