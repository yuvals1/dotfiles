-- haskell-tools-config.lua
return {
  'mrcjkb/haskell-tools.nvim',
  rversion = '^3',
  ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  config = function()
    local ht = require 'haskell-tools'
    local bufnr = vim.api.nvim_get_current_buf()
    local def_opts = { noremap = true, silent = true }

    -- haskell-tools configuration
    vim.g.haskell_tools = {
      hls = {
        on_attach = function(client, bufnr)
          local opts = vim.tbl_extend('keep', def_opts, { buffer = bufnr })
          -- Your custom keymaps here
          vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
          vim.keymap.set('n', '<space>hf', ht.repl.toggle, opts)
        end,
      },
      tools = {
        codeLens = {
          autoRefresh = true,
        },
        hoogle = {
          mode = 'auto', -- Changed from "telescope" to "auto"
        },
        repl = {
          handler = 'builtin',
          builtin = {
            cmd = { '/opt/homebrew/bin/ghci' }, -- Path to Homebrew-installed GHCi
          },
        },
      },
    }

    -- Suggested keymaps that do not depend on haskell-language-server
    local ht_bufnr = vim.api.nvim_get_current_buf()
    vim.keymap.set('n', '<leader>rr', ht.repl.toggle, { buffer = ht_bufnr, desc = 'Toggle GHCi REPL' })
    vim.keymap.set('n', '<leader>rf', function()
      ht.repl.toggle(vim.api.nvim_buf_get_name(0))
    end, { buffer = ht_bufnr, desc = 'Toggle GHCi REPL for current file' })
    vim.keymap.set('n', '<leader>rq', ht.repl.quit, { buffer = ht_bufnr, desc = 'Quit GHCi REPL' })
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim', -- optional
  },
}
