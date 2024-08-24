-- File: lua/custom/plugins/iron/repl.lua
local iron = require 'iron.core'

local M = {}

M.custom_repl_open_cmd = function(bufnr)
  local width = math.floor(vim.o.columns * 0.4)
  vim.cmd('botright vertical ' .. width .. 'split')
  vim.api.nvim_win_set_buf(0, bufnr)
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.api.nvim_buf_set_keymap(bufnr, 't', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
  return win
end

M.send_to_repl = function(code)
  iron.send(vim.bo.filetype, code)
  -- Switch back to normal mode
  vim.cmd 'stopinsert'
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
end

return M
