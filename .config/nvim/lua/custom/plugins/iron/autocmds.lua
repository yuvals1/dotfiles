local M = {}

M.setup = function()
  vim.api.nvim_create_autocmd('TermOpen', {
    pattern = 'term://*',
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.cmd 'startinsert'
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { buffer = true, noremap = true, silent = true })
    end,
  })

  vim.opt.ttimeoutlen = 0

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'iron',
    callback = function()
      vim.keymap.set('i', 'jk', '<Esc>', { buffer = true, noremap = true, silent = true })
      vim.keymap.set('n', 'i', 'i', { buffer = true, noremap = true, silent = true })
    end,
  })
end

return M
