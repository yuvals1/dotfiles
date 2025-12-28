local parsers = {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline',
  'query', 'vim', 'vimdoc', 'yaml', 'json', 'typescript', 'javascript', 'python',
  'toml', 'rust', 'ruby', 'svelte', 'sql', 'regex', 'make', 'dockerfile', 'cmake',
  'css', 'scss', 'cpp', 'java', 'haskell', 'ocaml', 'elixir', 'go', 'php', 'perl',
  'r', 'clojure', 'pascal',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    -- Add runtime/queries to runtimepath for query files
    local plugin_path = vim.fn.stdpath('data') .. '/lazy/nvim-treesitter'
    vim.opt.runtimepath:prepend(plugin_path .. '/runtime')

    vim.treesitter.language.register('bash', 'zsh')
    vim.treesitter.language.register('ruby', 'conf')
    vim.treesitter.language.register('ruby', 'cfg')

    -- Enable treesitter highlighting and indentation for all filetypes
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        local ok = pcall(vim.treesitter.start)
        if ok then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- Ruby needs additional regex highlighting
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'ruby',
      callback = function()
        vim.bo.syntax = 'on'
      end,
    })
  end,
}
