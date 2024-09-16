return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      size = 20,
      open_mapping = [[<C-t>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = false,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = false,
      direction = 'horizontal',
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'single',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    },
    config = function(_, opts)
      require('toggleterm').setup(opts)
      -- Only set keymaps for ToggleTerm buffers
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*toggleterm#*",
        callback = function()
          local opts = { buffer = 0 }
          -- vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
          -- vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
          vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        end
      })
    end,
  },
}
