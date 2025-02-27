return {
  'MagicDuck/grug-far.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('grug-far').setup {
      -- Default configuration
      window = {
        width = 0.6,
        height = 0.7,
        border = 'rounded',
      },
      auto_select_first_match = true,
      auto_search_on_input = true,
      preview_lines = 10,
      keymaps = {
        -- You can customize keymaps here
        -- For example:
        -- ["<C-j>"] = "next_match",
        -- ["<C-k>"] = "prev_match",
      },
    }

    -- Set up a keymap to open grug-far
    vim.keymap.set('n', '<leader>fr', require('grug-far').open, { desc = 'Open grug-far' })
    vim.keymap.set('v', '<leader>fr', require('grug-far').with_visual_selection, { desc = 'Open grug-far with selection' })
  end,
}
