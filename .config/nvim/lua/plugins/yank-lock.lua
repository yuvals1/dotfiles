return {
  'daltongd/yanklock.nvim', -- Changed from 'dir'
  opts = {
    notify = true,
  },
  keys = {
    {
      '<leader>yl',
      function()
        require('yanklock').toggle()
      end,
      desc = 'yanklock toggle',
    },
  },
}
