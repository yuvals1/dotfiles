-- json.lua
return {
  mason = { 'json-lsp', 'prettier' },
  lsp = {
    jsonls = {},
  },
  formatters = {
    json = { 'prettier' },
    jsonc = { 'prettier' },
  },
  linters = {
    -- You can add JSON linters here if desired.
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
  --       if ctx.filename:match '%.json$' then
  --         table.insert(args, '--parser')
  --         table.insert(args, 'json')
  --       end
  --       return args
  --     end,
  --     stdin = true,
  --   },
  -- },
}
