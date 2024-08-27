return {
  'prettier/vim-prettier',
  run = 'yarn install --frozen-lockfile --production',
  ft = {
    'javascript',
    'typescript',
    'css',
    'less',
    'scss',
    'json',
    'graphql',
    'markdown',
    'vue',
    'svelte',
    'yaml',
    'html',
  },
  config = function()
    -- Enable auto formatting on save
    vim.g['prettier#autoformat'] = 1
    vim.g['prettier#autoformat_require_pragma'] = 0

    -- Set Prettier CLI options
    vim.g['prettier#config#print_width'] = 80
    vim.g['prettier#config#tab_width'] = 2
    vim.g['prettier#config#use_tabs'] = 'false'
    vim.g['prettier#config#semi'] = 'true'
    vim.g['prettier#config#single_quote'] = 'false'
    vim.g['prettier#config#bracket_spacing'] = 'true'
    vim.g['prettier#config#jsx_bracket_same_line'] = 'false'
    vim.g['prettier#config#arrow_parens'] = 'always'
    vim.g['prettier#config#trailing_comma'] = 'es5'
    vim.g['prettier#config#parser'] = 'babylon'

    -- Key mapping for manual formatting
    vim.api.nvim_set_keymap('n', '<Leader>p', ':Prettier<CR>', { noremap = true, silent = true })
  end,
}
