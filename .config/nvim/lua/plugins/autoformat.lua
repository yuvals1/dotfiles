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
      jsonc = { 'prettier' },
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
      -- Updated Prettier configuration
      prettier = {
        command = 'prettier',
        args = function(self, ctx)
          local args = { '--stdin-filepath', '$FILENAME' }
          -- Check if .prettierrc exists in the project root
          local prettier_config = vim.fn.findfile('.prettierrc', vim.fn.getcwd() .. ';')
          if prettier_config ~= '' then
            table.insert(args, '--config')
            table.insert(args, prettier_config)
          else
            -- Fallback to default options if .prettierrc is not found
            vim.list_extend(args, {
              '--single-quote',
              '--trailing-comma',
              'es5',
              '--print-width',
              '130',
            })
          end

          -- Add parser for JSON files
          if ctx.filename:match '%.json$' then
            table.insert(args, '--parser')
            table.insert(args, 'json')
          end

          return args
        end,
        stdin = true,
      },
    },
  },
}
