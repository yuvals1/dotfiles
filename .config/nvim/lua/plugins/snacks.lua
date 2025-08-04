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
        os = { 
          edit = vim.fn.expand('~/.local/bin/lazygit-nvim-edit') .. ' {{filename}}',
          editAtLine = vim.fn.expand('~/.local/bin/lazygit-nvim-edit') .. ' {{filename}}',
        },
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
  config = function(_, opts)
    require('snacks').setup(opts)
    
    -- Yazi-style file selection for lazygit
    local group = vim.api.nvim_create_augroup('LazyGitFileSelection', { clear = true })
    local selection_file = '/tmp/lazygit-selected-file'
    
    -- Clean up on startup
    vim.fn.delete(selection_file)
    
    -- Store reference to lazygit window
    local lazygit_win = nil
    
    -- Track when lazygit opens
    vim.api.nvim_create_autocmd('TermOpen', {
      group = group,
      pattern = '*lazygit*',
      callback = function()
        -- Find the lazygit floating window
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname:match('term://.*lazygit') then
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= '' then
              lazygit_win = win
              break
            end
          end
        end
        
        -- Set up a timer to check for file selection
        local timer = vim.loop.new_timer()
        timer:start(50, 50, vim.schedule_wrap(function()
          local ok, content = pcall(vim.fn.readfile, selection_file)
          if ok and content and #content > 0 then
            local file = vim.trim(content[1])
            
            -- Stop timer and clean up
            timer:stop()
            vim.fn.delete(selection_file)
            
            -- Close lazygit window
            if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
              vim.api.nvim_win_close(lazygit_win, false)
            end
            
            -- Open the file
            vim.cmd('edit ' .. vim.fn.fnameescape(file))
            
            -- Reopen lazygit when done editing
            vim.api.nvim_create_autocmd('BufLeave', {
              buffer = vim.api.nvim_get_current_buf(),
              once = true,
              callback = function()
                vim.defer_fn(function()
                  Snacks.lazygit()
                end, 50)
              end,
            })
          end
        end))
        
        -- Clean up timer when lazygit closes
        vim.api.nvim_create_autocmd('TermClose', {
          pattern = '*lazygit*',
          once = true,
          callback = function()
            timer:stop()
          end,
        })
      end,
    })
  end,
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
