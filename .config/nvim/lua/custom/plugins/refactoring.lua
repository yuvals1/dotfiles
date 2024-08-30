return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim', -- Optional, for Telescope integration
  },
  config = function()
    require('refactoring').setup {
      -- Prompt for return type in supported languages
      prompt_func_return_type = {
        go = true,
        java = true,
        cpp = true,
        c = true,
        h = true,
        hpp = true,
        cxx = true,
      },
      -- Prompt for function parameters in supported languages
      prompt_func_param_type = {
        go = true,
        java = true,
        cpp = true,
        c = true,
        h = true,
        hpp = true,
        cxx = true,
      },
      -- Add any custom printf statements here
      printf_statements = {},
      -- Add any custom print variable statements here
      print_var_statements = {},
    }

    -- Load refactoring Telescope extension
    require('telescope').load_extension 'refactoring'

    -- Remaps for the refactoring operations
    vim.keymap.set('x', '<leader>re', function()
      require('refactoring').refactor 'Extract Function'
    end)
    vim.keymap.set('x', '<leader>rf', function()
      require('refactoring').refactor 'Extract Function To File'
    end)
    vim.keymap.set('x', '<leader>rv', function()
      require('refactoring').refactor 'Extract Variable'
    end)
    vim.keymap.set('n', '<leader>rI', function()
      require('refactoring').refactor 'Inline Function'
    end)
    vim.keymap.set({ 'n', 'x' }, '<leader>ri', function()
      require('refactoring').refactor 'Inline Variable'
    end)
    vim.keymap.set('n', '<leader>rb', function()
      require('refactoring').refactor 'Extract Block'
    end)
    vim.keymap.set('n', '<leader>rbf', function()
      require('refactoring').refactor 'Extract Block To File'
    end)

    -- Remaps for the debugging operations
    vim.keymap.set('n', '<leader>rp', function()
      require('refactoring').debug.printf { below = false }
    end)
    vim.keymap.set({ 'x', 'n' }, '<leader>rv', function()
      require('refactoring').debug.print_var()
    end)
    vim.keymap.set('n', '<leader>rc', function()
      require('refactoring').debug.cleanup {}
    end)

    -- Remap to open Telescope refactoring menu
    vim.keymap.set({ 'n', 'x' }, '<leader>rr', function()
      require('telescope').extensions.refactoring.refactors()
    end)
  end,
}
