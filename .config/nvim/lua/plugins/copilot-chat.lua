return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim' },
    },
    build = 'make tiktoken', -- If you want token counting
    keys = {
      -- Quick chat with Copilot
      {
        '<leader>cc',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = 'CopilotChat - Quick chat',
      },
      -- Open Copilot Chat window
      {
        '<leader>ct',
        '<cmd>CopilotChatToggle<cr>',
        desc = 'CopilotChat - Toggle chat window',
      },
      -- Code explanations
      {
        '<leader>ce',
        '<cmd>CopilotChatExplain<cr>',
        desc = 'CopilotChat - Explain code',
        mode = { 'n', 'v' },
      },
      -- Code review
      {
        '<leader>cr',
        '<cmd>CopilotChatReview<cr>',
        desc = 'CopilotChat - Review code',
        mode = { 'n', 'v' },
      },
      -- Generate unit tests
      {
        '<leader>ct',
        '<cmd>CopilotChatTests<cr>',
        desc = 'CopilotChat - Generate tests',
        mode = { 'n', 'v' },
      },
      -- Fix issues in code
      {
        '<leader>cf',
        '<cmd>CopilotChatFix<cr>',
        desc = 'CopilotChat - Fix code',
        mode = { 'n', 'v' },
      },
      -- Generate documentation
      {
        '<leader>cd',
        '<cmd>CopilotChatDocs<cr>',
        desc = 'CopilotChat - Document code',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      debug = false, -- Enable debug logging
      window = {
        layout = 'float', -- 'vertical', 'horizontal', 'float', 'replace'
        relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
        border = 'rounded', -- 'none', 'single', 'double', 'rounded'
        width = 0.8, -- fractional width of parent
        height = 0.6, -- fractional height of parent
      },
      model = 'claude-3.5-sonnet', -- Using Claude instead of GPT
      show_help = true, -- Show help text for CopilotChatInPlace
      auto_follow_cursor = true, -- Follow cursor in chat window
      auto_insert_mode = true, -- Enter insert mode when opening chat window
    },
  },
}
