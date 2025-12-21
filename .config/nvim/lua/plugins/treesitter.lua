return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    vim.treesitter.language.register('bash', 'zsh')
    vim.treesitter.language.register('ruby', 'conf')
    vim.treesitter.language.register('ruby', 'cfg')

    require('nvim-treesitter').setup({})

    -- Install parsers
    require('nvim-treesitter').install({
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'yaml',
      'json',
      'typescript',
      'javascript',
      'python',
      'toml',
      'rust',
      'ruby',
      'svelte',
      'sql',
      'regex',
      'make',
      'dockerfile',
      'cmake',
      'css',
      'scss',
      'cpp',
      'java',
      'haskell',
      'ocaml',
      'elixir',
      'go',
      'php',
      'perl',
      'r',
      'clojure',
      'pascal',
    })

    -- Enable treesitter highlighting for all filetypes
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
