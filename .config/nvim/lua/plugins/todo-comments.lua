-- lua/plugins/todo-comments.lua
return {
  'folke/todo-comments.nvim',
  cmd = { 'TodoQuickFix', 'TodoLocList', 'TodoTelescope' },
  event = 'VeryLazy', -- Changed from BufReadPost and BufNewFile
  dependencies = {
    {
      'nvim-lua/plenary.nvim',
      lazy = true,
    },
  },
  opts = {
    keywords = {
      DEBUG = { icon = '', color = 'test', alt = { 'DEBUGGING', 'DBUG' } },
    },
    merge_keywords = true,
    highlight = {
      pattern = [[.*<(KEYWORDS)\s*:]], -- Adjusted pattern to work with hidden files
      comments_only = false, -- Allow highlighting in all files, not just comments
    },
    search = {
      pattern = [[\b(KEYWORDS):]], -- Adjusted search pattern
    },
  },
  keys = {
    { '<leader>td', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
    { '<leader>tD', '<cmd>TodoTelescope keywords=DEBUG,NOTE<cr>', desc = 'Todo/Debug/Note' },
  },
  config = function(_, opts)
    require('todo-comments').setup(opts)
  end,
}

-- Supported keywords:
--TODO:
--NOTE:
--INFO:
--WARNING:
--HACK:
--FIXME:
--BUG:
--DEBUG:
