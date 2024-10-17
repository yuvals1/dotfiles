-- Brewfile handling
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { 'Brewfile' },
  callback = function()
    -- Set the filetype to ruby for syntax highlighting
    vim.bo.filetype = 'ruby'

    -- Create a new augroup for this buffer
    local augroup = vim.api.nvim_create_augroup('BrewfileSettings', { clear = true })

    -- Use FileType event to apply Ruby settings, but allow overrides
    vim.api.nvim_create_autocmd('FileType', {
      group = augroup,
      buffer = 0, -- Apply to current buffer only
      callback = function()
        -- Apply Ruby settings
        vim.bo.syntax = 'ruby'

        -- But immediately restore any mappings that might have been overwritten
        vim.api.nvim_exec_autocmds('User', { pattern = 'BrewfileKeepMappings', modeline = false })
      end,
    })

    -- Trigger an event that plugins can use to ensure their mappings are preserved
    vim.api.nvim_exec_autocmds('User', { pattern = 'BrewfileKeepMappings', modeline = false })
  end,
})
