-- Load options
require 'options'
require 'autocmds'
require 'keymaps'
require 'file-cmds'
require 'python'
require 'cursor-movement'

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