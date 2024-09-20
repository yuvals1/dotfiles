return {
  'MagicDuck/grug-far.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- optional, for file icons
  },
  config = function()
    local grug_far = require 'grug-far'
    grug_far.setup {
      -- Options go here. For example:
      -- engine = "ripgrep", -- or "astgrep"
      -- debounceMs = 100,
      -- flags = {
      --   -- Add any default flags you want here
      -- },
      -- You can customize keymaps here if desired
    }

    -- Set up a keybinding to open grug-far
    vim.keymap.set('n', '<leader>fr', ':GrugFar<CR>', { noremap = true, silent = true })

    -- Optional: Set up a keybinding to open grug-far with the word under the cursor
    vim.keymap.set('n', '<leader>fw', function()
      grug_far.open { prefills = { search = vim.fn.expand '<cword>' } }
    end, { noremap = true, silent = true })

    -- Optional: Set up a keybinding to open grug-far with the visual selection
    vim.keymap.set('v', '<leader>fv', function()
      grug_far.with_visual_selection()
    end, { noremap = true, silent = true })
  end,
}
