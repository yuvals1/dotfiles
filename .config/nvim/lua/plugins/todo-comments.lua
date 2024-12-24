-- lua/plugins/todo-comments.lua
return {
  'folke/todo-comments.nvim',
  cmd = { 'TodoQuickFix', 'TodoLocList', 'TodoTelescope' },
  event = 'VeryLazy',
  dependencies = {
    {
      'nvim-lua/plenary.nvim',
      lazy = true,
    },
  },
  opts = {
    keywords = {
      -- Your existing keywords
      DEBUG = { icon = '󰍉', color = '#FF00FF', alt = { 'DEBUGGING', 'DBUG' } },
      WORK = { icon = '🏢', color = '#4A90E2', alt = { 'JOB', 'TASK' } },
      LEARNING = { icon = '📚', color = '#FF00FF', alt = { 'STUDY', 'READ' } },
      MEETING = { icon = '🤝', color = '#9B59B6', alt = { 'MEET', 'APPOINTMENT' } },
      BREAK_TIME = { icon = '☕', color = '#2ECC71', alt = { 'REST', 'PAUSE' } },
      BAD_BEHAVIOR = { icon = '⚠️', color = '#E74C3C', alt = { 'BAD', 'MISBEHAVIOR' } },
      SLEEP = { icon = '😴', color = '#F39C12', alt = { 'REST', 'NAP' } },
      EXERCISE = { icon = '🏋️', color = '#1ABC9C', alt = { 'WORKOUT', 'TRAINING' } },
      -- Adding new status keywords
      FAIL = { icon = '❌', color = '#DC2626', alt = { 'FAILED', 'FAILURE' } },
      DONE = { icon = '✅', color = '#22C55E', alt = { 'COMPLETED', 'FINISHED' } },
      IN_PROGRESS = { icon = '🔄', color = '#FBBF24', alt = { 'WIP', 'ONGOING' } },
    },
    merge_keywords = true,
    highlight = {
      pattern = [[.*<?(KEYWORDS)\s*]], -- Simpler pattern that works with or without colon
      before = '', -- no highlight before the keyword
      keyword = 'wide', -- highlight the keyword
      after = '', -- no highlight after the keyword
      comments_only = false, -- Allow highlighting in all files, not just comments
    },
    search = {
      pattern = [[\b(KEYWORDS)\b]], -- Simple word boundary match
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
--WORK:
--LEARNING:
--MEETING:
--BREAK_TIME:
--BAD_BEHAVIOR:
--SLEEP:
--EXERCISE:
