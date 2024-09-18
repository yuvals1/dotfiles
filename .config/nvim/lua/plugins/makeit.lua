return {
  { -- makeit.nvim plugin
    'Zeioth/makeit.nvim',
    cmd = { 'MakeitOpen', 'MakeitToggleResults', 'MakeitRedo' },
    dependencies = { 'stevearc/overseer.nvim' },
    opts = {},
    keys = {
      { '<leader>mo', '<cmd>MakeitOpen<cr>', desc = 'Open Makeit options' },
      { '<leader>mt', '<cmd>MakeitToggleResults<cr>', desc = 'Toggle Makeit results' },
      { '<leader>mr', '<cmd>MakeitRedo<cr>', desc = 'Redo last Makeit command' },
      { '<leader>ms', '<cmd>MakeitStop<cr>', desc = 'Stop Makeit tasks' },
    },
  },
  { -- overseer.nvim dependency
    'stevearc/overseer.nvim',
    commit = '400e762648b70397d0d315e5acaf0ff3597f2d8b',
    cmd = { 'MakeitOpen', 'MakeitToggleResults', 'MakeitRedo' },
    opts = {
      task_list = {
        direction = 'bottom',
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
  },
}
