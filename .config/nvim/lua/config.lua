local function require_all(directory)
  local config_path = vim.fn.stdpath 'config'
  local lua_pattern = config_path .. '/lua/' .. directory .. '/*.lua'
  for _, file in ipairs(vim.fn.glob(lua_pattern, false, true)) do
    local module = file:match '([^/]+)%.lua$'
    if module then
      require(directory .. '.' .. module)
    end
  end
end
-- Load options
require 'options'
require 'file-cmds'
require 'python-host'
require 'clipboard_keymaps'
require 'brewfile-handling'
require 'highlight-yank'
require 'open-files'

-- Load all keymap files
require_all 'keymaps'

-- Set leader key (optional, but recommended for the default keymapping)
vim.g.mapleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins
require('lazy').setup 'plugins'
