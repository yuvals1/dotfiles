local parsers = {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline',
  'query', 'vim', 'vimdoc', 'yaml', 'json', 'typescript', 'javascript', 'python',
  'toml', 'rust', 'ruby', 'svelte', 'sql', 'regex', 'make', 'dockerfile', 'cmake',
  'css', 'scss', 'cpp', 'java', 'haskell', 'ocaml', 'elixir', 'go', 'php', 'perl',
  'r', 'clojure', 'pascal',
}

return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    vim.treesitter.language.register('bash', 'zsh')
    vim.treesitter.language.register('ruby', 'conf')
    vim.treesitter.language.register('ruby', 'cfg')

    local ts = require('nvim-treesitter')

    if type(ts.install) == 'function' then
      -- New API
      ts.setup({})
      ts.install(parsers)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function() pcall(vim.treesitter.start) end,
      })
    else
      -- Old API
      require('nvim-treesitter.configs').setup({
        ensure_installed = parsers,
        auto_install = true,
        highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
        indent = { enable = true, disable = { 'ruby' } },
      })
    end
  end,
}
