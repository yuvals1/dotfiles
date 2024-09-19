-- Add this to your Neovim configuration file (e.g., init.lua)

-- Helper function to get file path and parent directory
local function get_file_info()
  local filepath = vim.fn.expand '%:p'
  local parent_dir = vim.fn.fnamemodify(filepath, ':h')
  return filepath, parent_dir
end

-- Function to open new tmux window
_G.copy_path_and_open_tmux_window = function()
  local filepath, parent_dir = get_file_info()
  vim.fn.setreg('+', filepath)
  local tmux_cmd = string.format("tmux new-window 'cd %s && $SHELL'", parent_dir)
  vim.fn.system(tmux_cmd)
  print 'Filepath copied and new tmux window opened in parent directory.'
end

-- Function to open new vertical pane
_G.copy_path_and_open_tmux_vertical_pane = function()
  local filepath, parent_dir = get_file_info()
  vim.fn.setreg('+', filepath)
  local tmux_cmd = string.format("tmux split-window -h 'cd %s && $SHELL'", parent_dir)
  vim.fn.system(tmux_cmd)
  print 'Filepath copied and new vertical tmux pane opened in parent directory.'
end

-- Function to open new horizontal pane
_G.copy_path_and_open_tmux_horizontal_pane = function()
  local filepath, parent_dir = get_file_info()
  vim.fn.setreg('+', filepath)
  local tmux_cmd = string.format("tmux split-window -v 'cd %s && $SHELL'", parent_dir)
  vim.fn.system(tmux_cmd)
  print 'Filepath copied and new horizontal tmux pane opened in parent directory.'
end

-- Set up the keybindings (change these to your preferred key combinations)
vim.api.nvim_set_keymap('n', '<leader>tw', [[<cmd>lua _G.copy_path_and_open_tmux_window()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tv', [[<cmd>lua _G.copy_path_and_open_tmux_vertical_pane()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>th', [[<cmd>lua _G.copy_path_and_open_tmux_horizontal_pane()<CR>]], { noremap = true, silent = true })
