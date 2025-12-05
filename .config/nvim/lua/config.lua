require 'env.node'

-- Add Mason bin to PATH early, before LSP servers are enabled
-- This ensures vim.lsp.enable() can find Mason-installed language servers
local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
end

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
require 'config.indent'
-- require 'clipboard.clipboard_keymaps'
require 'clipboard.yank-with-path'
require 'highlight-yank'
require 'open-files'

-- Load all keymap files
require_all 'keymaps'
require_all 'others'

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
require('lazy').setup('plugins', {
  rocks = {
    enabled = false,
  },
})
