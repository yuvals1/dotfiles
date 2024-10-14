return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPost', 'BufNewFile' },
  build = ':TSUpdate',
  opts = {
    incremental_selection = {
      enable = true,
      keymaps = {
        -- init_selection = '<C-space>',
        -- node_incremental = '<C-space>',
        -- scope_incremental = false,
        -- node_decremental = '<bs>',
      },
    },
    ensure_installed = {
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
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
  },
  config = function(_, opts)
    vim.treesitter.language.register('bash', 'zsh')
    vim.treesitter.language.register('ruby', 'conf')
    vim.treesitter.language.register('ruby', 'cfg')
    require('nvim-treesitter.configs').setup(opts)
  end,
}
