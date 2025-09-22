local M = {}

-- Open a TUI command in a dedicated terminal tab and auto-close on exit
-- opts = { cwd = string (optional) }
local function open_in_terminal_tab(cmd, opts)
  opts = opts or {}

  if vim.fn.executable(cmd) ~= 1 then
    vim.notify(cmd .. ' not found on PATH', vim.log.levels.ERROR)
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
  local chan = vim.fn.termopen(cmd, { cwd = cwd })
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

