-- Ensure Neovim uses the modern Node.js runtime before plugins load (required for pyright on Linux ARM)
local M = {}

local node20_bin = '/home/jetson/.nvm/versions/node/v20.19.5/bin'

local function running_on_linux_arm()
  local uname = vim.loop.os_uname()
  local sys = (uname.sysname or ''):lower()
  local mach = (uname.machine or ''):lower()

  if sys:find('linux') and (mach:find('aarch64') or mach:find('arm')) then
    return true
  end
  return false
end

local function ensure_node20_in_path()
  if not running_on_linux_arm() then
    return
  end

  local existing_path = vim.env.PATH or ''
  if existing_path == '' then
    vim.env.PATH = node20_bin
    return
  end

  local entries = vim.split(existing_path, ':', { plain = true })
  local pruned = {}
  for _, entry in ipairs(entries) do
    if entry ~= '' and entry ~= node20_bin then
      table.insert(pruned, entry)
    end
  end

  if #pruned > 0 then
    vim.env.PATH = node20_bin .. ':' .. table.concat(pruned, ':')
  else
    vim.env.PATH = node20_bin
  end
end

ensure_node20_in_path()

return M
