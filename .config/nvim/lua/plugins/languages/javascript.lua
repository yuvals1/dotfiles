-- javascript.lua
return {
  mason = { 'typescript-language-server', 'prettier', 'eslint_d' },
  lsp = {
    ts_ls = {},
  },
  formatters = {
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescriptreact = { 'prettier' },
    html = { 'prettier' },
    css = { 'prettier' },
    scss = { 'prettier' },
  },
  linters = {
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    javascriptreact = { 'eslint_d' },
    typescriptreact = { 'eslint_d' },
  },
  -- formatter_options = {
  --   prettier = {
  --     args = function(ctx)
  --       local args = { '--stdin-filepath', ctx.filename }
  --       local prettier_config = vim.fn.findfile('.prettierrc', vim.fn.getcwd() .. ';')
  --       if prettier_config ~= '' then
  --         table.insert(args, '--config')
  --         table.insert(args, prettier_config)
  --       else
  --         vim.list_extend(args, {
  --           '--single-quote',
  --           '--trailing-comma',
  --           'es5',
  --           '--print-width',
  --           '130',
  --         })
  --       end
  --       if ctx.filename:match('%.json$') then
  --         table.insert(args, '--parser')
  --         table.insert(args, 'json')
  --       end
  --       return args
  --     end,
  --     stdin = true,
  --   },
  -- },
}
