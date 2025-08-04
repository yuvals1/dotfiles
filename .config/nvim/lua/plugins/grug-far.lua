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
        ["q"] = "close",
      },
    }

    -- Set up a keymap to open grug-far
    vim.keymap.set('n', '<leader>fr', require('grug-far').open, { desc = 'Open grug-far' })
    vim.keymap.set('v', '<leader>fr', require('grug-far').with_visual_selection, { desc = 'Open grug-far with selection' })
    
    -- Search in current file only
    vim.keymap.set('n', '<leader>fc', function()
      require('grug-far').open({ prefills = { paths = vim.fn.expand("%") } })
    end, { desc = 'Search in current file' })
    vim.keymap.set('v', '<leader>fc', function()
      require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
    end, { desc = 'Search in current file with selection' })
  end,
}
