-- init.lua
local M = {}

-- Require the highlight module
local highlight = require 'plugins.lsp-and-tools.highlight'

-- Set a lower updatetime
vim.opt.updatetime = 500

-- Function to set up highlighting for each language server
local function setup_highlighting(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    highlight.setup { buf = bufnr }
  end
end

local function build_plugins(languages)
  return {
    require('plugins.lsp-and-tools.mason').setup(languages),
    require('plugins.lsp-and-tools.mason-tool-installer').setup(languages),
    require('plugins.lsp-and-tools.lspconfig').setup(languages, setup_highlighting),
    require('plugins.lsp-and-tools.conform').setup(languages),
    require('plugins.lsp-and-tools.lint').setup(languages),
    require('plugins.lsp-and-tools.keymaps').setup(),
  }
end

local function detect_profile()
  -- Allow explicit override via global or env var
  local override = vim.g.lsp_tools_profile or vim.env.NVIM_LSP_PROFILE
  if type(override) == 'string' and #override > 0 then
    return override
  end

  local uname = vim.loop.os_uname()
  local sys = (uname.sysname or ''):lower()
  local mach = (uname.machine or ''):lower()

  if sys:find('darwin') then
    return 'macos'
  end
  if sys:find('linux') and (mach:find('aarch64') or mach:find('arm')) then
    return 'linux_arm'
  end
  return 'default'
end

local profile = detect_profile()
local languages
if profile == 'macos' then
  languages = require 'plugins.lsp-and-tools.profiles.macos'
elseif profile == 'linux_arm' then
  languages = require 'plugins.lsp-and-tools.profiles.linux_arm'
else
  languages = require 'plugins.lsp-and-tools.profiles.default'
end

return build_plugins(languages)
