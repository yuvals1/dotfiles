-- Ensure Neovim uses a valid Node.js runtime before plugins load (required for npm-backed Mason tools on Linux ARM)
local M = {}

local function running_on_linux_arm()
  local uname = vim.loop.os_uname()
  local sys = (uname.sysname or ''):lower()
  local mach = (uname.machine or ''):lower()

  if sys:find('linux') and (mach:find('aarch64') or mach:find('arm')) then
    return true
  end
  return false
end

local function find_node_bin()
  -- Prefer what Neovim can already resolve from PATH.
  local npm_path = vim.fn.exepath 'npm'
  if npm_path ~= '' then
    return vim.fn.fnamemodify(npm_path, ':h')
  end

  -- Fallback: find the newest usable NVM node bin.
  local candidates = vim.fn.glob('/home/jetson/.nvm/versions/node/*/bin', false, true)
  table.sort(candidates, function(a, b)
    return a > b
  end)

  for _, bin in ipairs(candidates) do
    if vim.fn.executable(bin .. '/node') == 1 and vim.fn.executable(bin .. '/npm') == 1 then
      return bin
    end
  end

  return nil
end

local function ensure_node_in_path()
  if not running_on_linux_arm() then
    return
  end

  local node_bin = find_node_bin()
  if not node_bin then
    return
  end

  local existing_path = vim.env.PATH or ''
  if existing_path == '' then
    vim.env.PATH = node_bin
    return
  end

  local entries = vim.split(existing_path, ':', { plain = true })
  local pruned = {}
  for _, entry in ipairs(entries) do
    if entry ~= '' and entry ~= node_bin then
      table.insert(pruned, entry)
    end
  end

  if #pruned > 0 then
    vim.env.PATH = node_bin .. ':' .. table.concat(pruned, ':')
  else
    vim.env.PATH = node_bin
  end
end

ensure_node_in_path()

return M
