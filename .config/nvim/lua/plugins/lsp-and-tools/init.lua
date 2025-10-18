-- init.lua
local language_utils = require 'plugins.lsp-and-tools.language_utils'
local M = {}

vim.opt.updatetime = 500

local function build_plugins(languages)
  return {
    require('plugins.lsp-and-tools.mason').setup(languages),
    require('plugins.lsp-and-tools.mason-tool-installer').setup(languages),
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

local configs = language_utils.collect_configurations(languages)
require('plugins.lsp-and-tools.native').setup(configs)

return build_plugins(languages)
