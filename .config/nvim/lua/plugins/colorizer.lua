return {
  'NvChad/nvim-colorizer.lua',
  event = 'BufReadPre',
  opts = {
    options = {
      parsers = {
        css = true,
      },
    },
  },
}
