return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    -- You can add your custom configuration here
    indent = {
      char = '▏', -- You can change this to your preferred character
    },
    scope = {
      enabled = true,
      show_start = true,
      show_end = true,
    },
  },
  config = function(_, opts)
    require('ibl').setup(opts)
  end,
}
