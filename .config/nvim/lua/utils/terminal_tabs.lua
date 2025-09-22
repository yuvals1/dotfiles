local M = {}

local function resolve_executable(cmd)
  -- Prefer explicit env vars if exported, then common local dev paths, then PATH
  local home = vim.loop.os_homedir()
  local candidates = {}

  if cmd == 'lazygit' then
    local env = vim.fn.getenv('LAZYGIT_BIN')
    if env and env ~= '' then table.insert(candidates, env) end
    table.insert(candidates, home .. '/dev/lazygit/lazygit')
  elseif cmd == 'yazi' then
    local env = vim.fn.getenv('YAZI_BIN')
    if env and env ~= '' then table.insert(candidates, env) end
    table.insert(candidates, home .. '/dev/yazi/target/release/yazi')
  end

  -- Use the first executable candidate
  for _, path in ipairs(candidates) do
    if type(path) == 'string' and path ~= '' and vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- Fallback to whatever is on PATH
  local exepath = vim.fn.exepath(cmd)
  if exepath ~= nil and exepath ~= '' then
    return exepath
  end

  -- As a last resort, return the original command (may still succeed if shell resolves it)
  return cmd
end

-- Open a TUI command in a dedicated terminal tab and auto-close on exit
-- opts = { cwd = string (optional) }
local function open_in_terminal_tab(cmd, opts)
  opts = opts or {}

  local exe = resolve_executable(cmd)
  if type(exe) ~= 'string' or exe == '' or vim.fn.executable(exe) ~= 1 then
    vim.notify(cmd .. ' not found (checked PATH and local dev paths)', vim.log.levels.ERROR)
    return
  end

  local cwd = opts.cwd
  if not cwd or cwd == '' then
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= '' then
      cwd = vim.fn.fnamemodify(bufname, ':p:h')
    else
      cwd = vim.loop.cwd()
    end
  end

  vim.cmd('tabnew')
  local term_buf = vim.api.nvim_get_current_buf()
  local chan = vim.fn.termopen({ exe }, { cwd = cwd })
  if chan <= 0 then
    vim.notify('failed to start ' .. cmd, vim.log.levels.ERROR)
    if vim.fn.tabpagenr('$') > 1 then vim.cmd('tabclose') end
    return
  end
  vim.cmd('startinsert')

  vim.api.nvim_create_autocmd('TermClose', {
    buffer = term_buf,
    once = true,
    callback = function()
      if vim.fn.tabpagenr('$') > 1 then
        vim.cmd('tabclose')
      else
        vim.cmd('bdelete!')
      end
    end,
  })
end

function M.open_yazi_tab(opts)
  open_in_terminal_tab('yazi', opts)
end

function M.open_lazygit_tab(opts)
  open_in_terminal_tab('lazygit', opts)
end

-- Provide user commands for convenience
vim.api.nvim_create_user_command('YaziStandalone', function()
  M.open_yazi_tab()
end, { desc = 'Open Yazi in a terminal tab' })

vim.api.nvim_create_user_command('LazyGitStandalone', function()
  M.open_lazygit_tab()
end, { desc = 'Open Lazygit in a terminal tab' })

return M
