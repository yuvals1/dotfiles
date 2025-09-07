-- platform.lua
-- Detects platform/arch and applies platform-specific overrides.

local M = {}

-- Return platform information
function M.info()
  local uv = vim.loop
  local uname = uv.os_uname()
  local sysname = (uname.sysname or ''):lower()
  local machine = (uname.machine or ''):lower()

  local is_linux = sysname:find('linux') ~= nil
  local is_darwin = sysname:find('darwin') ~= nil
  local is_windows = sysname:find('windows') ~= nil

  local is_arm = machine:find('aarch64') ~= nil or machine:find('arm') ~= nil

  -- Heuristic for NVIDIA Jetson devices
  local function file_exists(path)
    return uv.fs_stat(path) ~= nil
  end
  local is_jetson = is_linux and (file_exists('/etc/nv_tegra_release') or file_exists('/etc/nv_tegra_version'))

  return {
    os = sysname,
    arch = machine,
    is_linux = is_linux,
    is_darwin = is_darwin,
    is_windows = is_windows,
    is_arm = is_arm,
    is_jetson = is_jetson,
  }
end

local function has_exec(bin)
  return vim.fn.executable(bin) == 1
end

-- Apply platform-specific removals/overrides to the aggregated configs.
-- Mutates and returns the configs table.
function M.apply_overrides(configs)
  local info = M.info()

  -- Build skip sets based on platform
  local skip_servers = {}
  local skip_tools = {}

  -- On Linux ARM (e.g., Jetson), a few Mason packages are not supported
  if info.is_linux and info.is_arm then
    -- Known unsupported binaries from logs
    skip_servers['lemminx'] = true -- XML LSP
    skip_servers['clangd'] = true -- C/C++ LSP
    -- Also avoid asking mason-tool-installer to install these as generic tools
    skip_tools['lemminx'] = true
    skip_tools['clangd'] = true

    -- If Go toolchain isn't available and mason has no prebuilt for this arch,
    -- avoid attempting to install Go-based tools/servers via Mason.
    if not has_exec('go') then
      skip_servers['gopls'] = true
      skip_tools['gofumpt'] = true
      skip_tools['golines'] = true
      skip_tools['golangci-lint'] = true
      -- Some packages use a different name in configs; normalize just in case
      skip_tools['golangcilint'] = true
    end
  end

  -- Filter LSP servers
  for server, _ in pairs(configs.lsp_servers or {}) do
    if skip_servers[server] then
      configs.lsp_servers[server] = nil
    end
  end

  -- Filter tools list, preserving order and uniqueness
  local filtered_tools = {}
  local seen = {}
  for _, tool in ipairs(configs.tools or {}) do
    if not skip_tools[tool] and not seen[tool] then
      table.insert(filtered_tools, tool)
      seen[tool] = true
    end
  end
  configs.tools = filtered_tools

  return configs
end

return M
