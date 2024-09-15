local M = {}

M.setup = function()
  -- Keybind for the git alias
  vim.keymap.set('n', '<leader>gc', function()
    vim.cmd 'terminal gt create -m '
    vim.cmd 'startinsert'
  end, { noremap = true, silent = true, desc = 'Git: Create commit with message' })
end

return M
