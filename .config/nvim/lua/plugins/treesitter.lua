local parsers = {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline',
  'query', 'vim', 'vimdoc', 'yaml', 'json', 'typescript', 'javascript', 'python',
  'toml', 'rust', 'ruby', 'svelte', 'sql', 'regex', 'make', 'dockerfile', 'cmake',
  'css', 'scss', 'cpp', 'java', 'haskell', 'ocaml', 'elixir', 'go', 'php', 'perl',
  'r', 'clojure', 'pascal',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',  -- Use old API with prebuilt parsers (works on all platforms)
  lazy = false,
  build = ':TSUpdate',
  config = function()
    vim.treesitter.language.register('bash', 'zsh')
    vim.treesitter.language.register('ruby', 'conf')
    vim.treesitter.language.register('ruby', 'cfg')

    require('nvim-treesitter.configs').setup({
      ensure_installed = parsers,
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
      indent = { enable = true, disable = { 'ruby' } },
    })
  end,
}
