-- Open pdf files with Preview
vim.api.nvim_create_autocmd('BufReadCmd', {
  pattern = '*.pdf',
  callback = function()
    local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
    vim.cmd('silent !open -a Preview ' .. filename)
    vim.cmd 'bdelete'
  end,
})

-- Open image files with Preview
vim.api.nvim_create_autocmd('BufReadCmd', {
  pattern = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.svg' },
  callback = function()
    local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
    vim.cmd('silent !open -a Preview ' .. filename)
    vim.cmd 'bdelete'
  end,
})

vim.api.nvim_create_user_command('DotPreview', function(opts)
  if vim.fn.executable 'dot' ~= 1 then
    vim.notify('Graphviz `dot` is not installed or not in PATH', vim.log.levels.ERROR)
    return
  end

  local input = vim.api.nvim_buf_get_name(0)
  if input == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.ERROR)
    return
  end

  local ext = vim.fn.fnamemodify(input, ':e')
  if ext ~= 'dot' then
    vim.notify('DotPreview expects a .dot file', vim.log.levels.ERROR)
    return
  end

  local output_type = opts.args ~= '' and opts.args or 'png'
  local allowed_types = {
    png = true,
    svg = true,
    pdf = true,
  }

  if not allowed_types[output_type] then
    vim.notify('DotPreview supports: png, svg, pdf', vim.log.levels.ERROR)
    return
  end

  vim.cmd 'write'

  local output = vim.fn.fnamemodify(input, ':r') .. '.' .. output_type
  local result = vim.fn.system {
    'dot',
    '-T' .. output_type,
    input,
    '-o',
    output,
  }

  if vim.v.shell_error ~= 0 then
    vim.notify(result, vim.log.levels.ERROR)
    return
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(output))
end, {
  nargs = '?',
  complete = function()
    return { 'png', 'svg', 'pdf' }
  end,
})
