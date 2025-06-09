return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = require 'plugins.gitsigns.signs',
      on_attach = function(bufnr)
        require('plugins.gitsigns.keymaps').setup(bufnr)
      end,
      -- Fix hunk navigation issues
      diff_opts = {
        algorithm = 'myers', -- Try 'myers', 'minimal', 'patience', or 'histogram'
        internal = false, -- Use external git diff
        indent_heuristic = true,
        linematch = nil, -- Disable line matching which can cause issues
      },
      -- Improve hunk detection
      max_file_length = 40000,
      preview_config = {
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },
    },
  },
}
