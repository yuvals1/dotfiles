return {
  'gcmt/vessel.nvim',
  event = 'VeryLazy',
  cmd = {
    'Marks',
    'Jumps',
  },
  keys = {
    { 'm.', desc = 'Vessel: Set Local Mark' },
    { 'm,', desc = 'Vessel: Set Global Mark' },
    { 'gl', desc = 'Vessel: View Local Jumps' },
    { 'gL', desc = 'Vessel: View External Jumps' },
    { 'gm', desc = 'Vessel: View Marks' },
  },
  opts = {
    create_commands = true,
    commands = {
      view_marks = 'Marks',
      view_jumps = 'Jumps',
    },
    window = {
      relativenumber = true,
      max_height = 20, -- Adjust as needed
    },
    marks = {
      toggle_mark = true,
      use_backtick = false,
    },
    jumps = {
      filter_empty_lines = true,
    },
  },
  config = function(_, opts)
    require('vessel').setup(opts)

    -- Set up keymaps
    vim.keymap.set('n', 'm.', '<Plug>(VesselSetLocalMark)', { silent = true })
    vim.keymap.set('n', 'm,', '<Plug>(VesselSetGlobalMark)', { silent = true })
    vim.keymap.set('n', 'gl', '<Plug>(VesselViewLocalJumps)', { silent = true })
    vim.keymap.set('n', 'gL', '<Plug>(VesselViewExternalJumps)', { silent = true })
    vim.keymap.set('n', 'gm', '<Plug>(VesselViewMarks)', { silent = true })
  end,
}
