return {
  'folke/snacks.nvim',
  priority = 1000, -- Important: high priority for early loading
  lazy = false, -- Don't lazy load since we need early setup
  opts = {
    -- Enable and configure bigfile
    bigfile = {
      enabled = true,
      -- Optional: customize bigfile settings
      size = 1 * 1024 * 1024, -- 1MB
      pattern = { '*' }, -- filetypes or patterns to apply to
      features = {
        'indent_blankline',
        'illuminate',
        'lsp',
        'treesitter',
        'syntax',
        'matchparen',
        'vimopts',
        'filetype',
      },
      setup = function(ctx)
        vim.b.minianimate_disable = true
        vim.schedule(function()
          vim.bo[ctx.buf].syntax = ctx.ft
        end)
      end,
    },
  },
  -- Key mappings for lazygit
  keys = {
    -- LazyGit mappings
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
    {
      '<leader>gf',
      function()
        Snacks.lazygit.log_file()
      end,
      desc = 'Lazygit Current File History',
    },
    {
      '<leader>gl',
      function()
        Snacks.lazygit.log()
      end,
      desc = 'Lazygit Log (cwd)',
    },
  },
}
