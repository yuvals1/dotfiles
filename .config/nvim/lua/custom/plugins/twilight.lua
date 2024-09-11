-- File: ~/.config/nvim/lua/plugins/twilight.lua

return {
  'folke/twilight.nvim',
  lazy = true,
  opts = {
    dimming = {
      alpha = 0.25, -- amount of dimming
      color = { 'Normal', '#ffffff' }, -- we try to get the foreground from the highlight groups or fallback color
      term_bg = '#000000', -- if guibg=NONE, this will be used to calculate text color
      inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
    },
    context = 10, -- amount of lines we will try to show around the current line
    treesitter = true, -- use treesitter when available for the filetype
    -- treesitter is used to automatically expand the visible text,
    -- but you can further control the types of nodes that should always be fully expanded
    expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
      'function',
      'method',
      'table',
      'if_statement',
    },
    exclude = {}, -- exclude these filetypes

    -- Additional options:
    alt_mode = 'all', -- alternatives: 'cursor', 'all'. When cursor, only the focused line is dimmed
    sync_git_blame = false, -- when true, the dimming will be synchronized with git blame information
    before = {}, -- table of lua functions to run before twilight starts
    after = {}, -- table of lua functions to run after twilight ends
    ignore = {}, -- list of file types to ignore (e.g., {"help", "NvimTree"})
    disable_diagnostics = false, -- when true, LSP and other diagnostics will be disabled in dimmed regions
    disable_telescope = false, -- when true, Telescope will be disabled in dimmed regions
    disable_git_blame = false, -- when true, git blame will be disabled in dimmed regions
    disable_cmp = false, -- when true, nvim-cmp will be disabled in dimmed regions
    disable_lsp = false, -- when true, LSP will be disabled in dimmed regions
    disable_treesitter = false, -- when true, TreeSitter will be disabled in dimmed regions
  },
  keys = {
    { '<leader>tt', '<cmd>Twilight<cr>', desc = 'Toggle Twilight' },
    { '<leader>te', '<cmd>TwilightEnable<cr>', desc = 'Enable Twilight' },
    { '<leader>td', '<cmd>TwilightDisable<cr>', desc = 'Disable Twilight' },
  },
}
