return {
  'ggandor/leap.nvim',
  enabled = true,
  keys = {
    { 'f', mode = { 'n', 'x', 'o' }, desc = 'Leap forward to' },
    { 'F', mode = { 'n', 'x', 'o' }, desc = 'Leap backward to' },
    { 'gf', mode = { 'n', 'x', 'o' }, desc = 'Leap from windows' },
  },
  config = function()
    local leap = require 'leap'
    leap.opts.safe_labels = {}

    vim.keymap.set({ 'n', 'x', 'o' }, 'f', '<Plug>(leap-forward)')
    vim.keymap.set({ 'n', 'x', 'o' }, 'F', '<Plug>(leap-backward)')
    vim.keymap.set({ 'n', 'x', 'o' }, 'gf', '<Plug>(leap-from-window)')
  end,
  dependencies = {
    'tpope/vim-repeat',
  },
}
