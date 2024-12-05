return {
  'ellisonleao/carbon-now.nvim',
  lazy = true,
  cmd = 'CarbonNow',
  ---@param opts cn.ConfigSchema
  opts = { [[ your custom config here ]] },
  vim.keymap.set('v', '<leader>cn', ':CarbonNow<CR>', { silent = true }),
}
