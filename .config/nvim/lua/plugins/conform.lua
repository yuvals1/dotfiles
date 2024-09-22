return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>fc',
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
      -- Update Python formatting to use isort and ruff
      python = {},
      toml = { 'taplo' },
      make = { 'checkmake' },
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
      checkmake = {
        command = 'checkmake',
        args = { "--format='{line}:{col} {severity}: {message}'" },
        stdin = false,
      },
      prettier = {
        command = 'prettier',
        args = function(self, ctx)
          local args = { '--stdin-filepath', '$FILENAME' }
          local prettier_config = vim.fn.findfile('.prettierrc', vim.fn.getcwd() .. ';')
          if prettier_config ~= '' then
            table.insert(args, '--config')
            table.insert(args, prettier_config)
          else
            vim.list_extend(args, {
              '--single-quote',
              '--trailing-comma',
              'es5',
              '--print-width',
              '130',
            })
          end
          if ctx.filename:match '%.json$' then
            table.insert(args, '--parser')
            table.insert(args, 'json')
          end
          return args
        end,
        stdin = true,
      },
      -- Replace black configuration with ruff configuration
      ruff = {
        command = 'ruff',
        args = function(self, ctx)
          local args = { 'format', '--stdin-filename', '$FILENAME', '-' }
          -- Check for pyproject.toml in the project root
          local pyproject = vim.fn.findfile('pyproject.toml', vim.fn.getcwd() .. ';')
          if pyproject ~= '' then
            table.insert(args, '--config')
            table.insert(args, pyproject)
          else
            -- Fallback to default options if pyproject.toml is not found
            table.insert(args, '--line-length')
            table.insert(args, '100')
          end
          return args
        end,
        stdin = true,
      },
      -- Keep isort configuration
      isort = {
        command = 'isort',
        args = function(self, ctx)
          local args = { '--quiet', '-' }
          -- Check for .isort.cfg or pyproject.toml in the project root
          local isort_config = vim.fn.findfile('.isort.cfg', vim.fn.getcwd() .. ';')
          local pyproject = vim.fn.findfile('pyproject.toml', vim.fn.getcwd() .. ';')
          if isort_config ~= '' then
            table.insert(args, '--settings-file')
            table.insert(args, isort_config)
          elseif pyproject ~= '' then
            table.insert(args, '--settings-file')
            table.insert(args, pyproject)
          else
            -- Fallback to default options if no config is found
            table.insert(args, '--profile')
            table.insert(args, 'black')
            table.insert(args, '--line-length')
            table.insert(args, '100')
          end
          return args
        end,
        stdin = true,
      },
    },
  },
}
