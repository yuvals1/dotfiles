-- adding the first 7 lines the first 7 lines to the original repro.lua file makes yazi bugs appear
-- Prepend your custom config directory to the runtime path
vim.opt.runtimepath:prepend '/Users/yuvals1/dotfiles/.config/new-nvim'

-- Adjust Lua's package.path
local lua_path = '/Users/yuvals1/dotfiles/.config/new-nvim/lua/?.lua'
local lua_path_init = '/Users/yuvals1/dotfiles/.config/new-nvim/lua/?/init.lua'
package.path = package.path .. ';' .. lua_path .. ';' .. lua_path_init

-- Load custom configurations
require 'custom.configs'

-- Original repro.lua content starts here
local root = vim.fn.fnamemodify('./.repro', ':p')

-- set stdpaths to use .repro
for _, name in ipairs { 'config', 'data', 'state', 'cache' } do
  vim.env[('XDG_%s_HOME'):format(name:upper())] = root .. '/' .. name
end

-- bootstrap lazy
local lazypath = root .. '/plugins/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

-- Add the plugins directory to the runtime path
local plugins_path = vim.fn.fnamemodify(vim.fn.expand '<sfile>:p:h' .. '/plugins', ':p')
vim.opt.runtimepath:append(plugins_path)

vim.g.mapleader = ' '

-- Debug function
local function debug_print(message)
  print(message)
  vim.cmd 'messages'
end

-- Combine built-in configurations with loaded plugin configurations
local plugins = {
  { 'catppuccin/nvim', name = 'catppuccin', opts = { flavour = 'macchiato' } },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup()
    end,
  },
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    keys = {
      { '-', '<cmd>Yazi<cr>', desc = 'Open yazi at the current file' },
      {
        '<leader>cw',
        '<cmd>Yazi cwd<cr>',
        desc = "Open the file manager in nvim's working directory",
      },
      {
        '<c-up>',
        '<cmd>Yazi toggle<cr>',
        desc = 'Resume the last yazi session',
      },
    },
    opts = { open_for_directories = false },
  },
  -- Specifically load the iron plugin
  { dir = plugins_path .. '/iron', name = 'iron' },
}

require('lazy').setup(plugins, {
  root = root .. '/plugins',
  install = { colorscheme = { 'catppuccin' } },
})

vim.cmd.colorscheme 'catppuccin'

-- Tmux navigation key mappings
local function tmux_navigate(direction)
  local cmd = string.format('silent !tmux select-pane -%s', direction)
  vim.cmd(cmd)
end

-- Function to check if we're in a tmux session
local function is_in_tmux()
  return vim.env.TMUX ~= nil
end

-- Function to navigate between Neovim windows or tmux panes
local function smart_navigate(direction)
  local cmd = vim.api.nvim_replace_termcodes(string.format('<C-%s>', direction), true, false, true)
  local win_number = vim.fn.winnr()
  vim.cmd(string.format('wincmd %s', direction))
  if win_number == vim.fn.winnr() and is_in_tmux() then
    tmux_navigate(direction:upper())
  end
end

-- Set up smart navigation mappings
vim.keymap.set('n', '<C-h>', function()
  smart_navigate 'h'
end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', function()
  smart_navigate 'j'
end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', function()
  smart_navigate 'k'
end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', function()
  smart_navigate 'l'
end, { noremap = true, silent = true })

-- Yazi mapping
vim.keymap.set('n', '-', '<cmd>Yazi<cr>', { noremap = true, silent = true, desc = 'Open Yazi at current file' })

-- Debug: Print loaded plugins
vim.api.nvim_create_user_command('DebugPlugins', function()
  for _, plugin in ipairs(require('lazy').plugins()) do
    debug_print('Loaded plugin: ' .. (plugin.name or plugin.dir or 'unnamed'))
  end
end, {})
