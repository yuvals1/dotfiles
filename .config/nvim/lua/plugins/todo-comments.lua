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
      DEBUG = { icon = '󰍉', color = '#FF00FF', alt = { 'DEBUGGING', 'DBUG' } },
      WORK = { icon = '🏢', color = '#4A90E2', alt = { 'JOB', 'TASK' } },
      LEARNING = { icon = '📚', color = '#FF00FF', alt = { 'STUDY', 'READ' } },
      MEETING = { icon = '🤝', color = '#9B59B6', alt = { 'MEET', 'APPOINTMENT' } },
      BREAK_TIME = { icon = '☕', color = '#2ECC71', alt = { 'REST', 'PAUSE' } },
      BAD_BEHAVIOR = { icon = '⚠️', color = '#E74C3C', alt = { 'BAD', 'MISBEHAVIOR' } },
      SLEEP = { icon = '😴', color = '#F39C12', alt = { 'REST', 'NAP' } },
      EXERCISE = { icon = '🏋️', color = '#1ABC9C', alt = { 'WORKOUT', 'TRAINING' } },
    },
    merge_keywords = true,
    highlight = {
      pattern = [[.*<(KEYWORDS)\s*:]], -- Adjusted pattern to work with hidden files
      comments_only = false, -- Allow highlighting in all files, not just comments
    },
    search = {
      pattern = [[\b(KEYWORDS):]], -- Adjusted search pattern
    },
    -- You can keep the colors table for reference or remove it if not needed
    -- colors = {
    --   error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
    --   warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
    --   info = { 'DiagnosticInfo', '#2563EB' },
    --   hint = { 'DiagnosticHint', '#10B981' },
    --   default = { 'Identifier', '#7C3AED' },
    --   test = { 'Identifier', '#FF00FF' },
    -- },
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
