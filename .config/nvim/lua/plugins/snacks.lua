return {
  'folke/snacks.nvim',
  priority = 1000, -- Important: high priority for early loading
  lazy = false, -- Don't lazy load since we need early setup
  opts = {
    -- Your other options

    lazygit = {
      configure = true,
      -- Use the default lazygit theme by providing specific config
      config = {
        os = { editPreset = 'nvim-remote' },
        gui = {
          nerdFontsVersion = '3',
          -- Explicitly set the default lazygit theme
          theme = {
            activeBorderColor = { 'green', 'bold' },
            searchingActiveBorderColor = { 'cyan', 'bold' },
            inactiveBorderColor = { 'default' },
            optionsTextColor = { 'blue' },
            selectedLineBgColor = { 'blue' },
            inactiveViewSelectedLineBgColor = { 'bold' },
            cherryPickedCommitBgColor = { 'cyan' },
            cherryPickedCommitFgColor = { 'blue' },
            markedBaseCommitBgColor = { 'yellow' },
            markedBaseCommitFgColor = { 'blue' },
            unstagedChangesColor = { 'red' },
            defaultFgColor = { 'default' },
          },
        },
      },
      win = {
        style = 'lazygit',
      },
    },

    bigfile = {
      enabled = true,
      size = 1 * 1024 * 1024, -- 1MB
      pattern = { '*' },
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
      '<c-g>',
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
