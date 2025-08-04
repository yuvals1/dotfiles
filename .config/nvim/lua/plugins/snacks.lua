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
          edit = 'nvim-from-lazygit {{filename}}',
          editAtLine = 'nvim-from-lazygit {{filename}}',
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
    
    -- Custom lazygit integration for file opening
    local group = vim.api.nvim_create_augroup('LazyGitIntegration', { clear = true })
    
    -- Clean up any leftover temp files on startup
    vim.fn.delete('/tmp/lazygit-edit-file')
    vim.fn.delete('/tmp/lazygit-edit-done')
    local timer = vim.loop.new_timer()
    local checking = false
    
    local function check_and_open_file()
      if checking then return end
      checking = true
      
      local ok, content = pcall(vim.fn.readfile, '/tmp/lazygit-edit-file')
      if ok and content and #content > 0 then
        local file = content[1]
        -- Clear the temp file
        vim.fn.writefile({}, '/tmp/lazygit-edit-file')
        
        -- Schedule opening the file in the main thread
        vim.schedule(function()
          -- Find and close the lazygit floating window
          local lazygit_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local bufname = vim.api.nvim_buf_get_name(buf)
            if bufname:match('term://.*lazygit') then
              -- Check if it's a floating window
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= '' then
                lazygit_win = win
                break
              end
            end
          end
          
          -- Close the floating window
          if lazygit_win then
            vim.api.nvim_win_close(lazygit_win, false)
          end
          
          -- Open the file
          vim.cmd('edit ' .. vim.fn.fnameescape(file))
          
          -- Set up autocmd to signal when we're done editing
          vim.api.nvim_create_autocmd({'BufLeave', 'BufWinLeave'}, {
            buffer = vim.api.nvim_get_current_buf(),
            once = true,
            callback = function()
              -- Signal that editing is complete
              vim.fn.writefile({}, '/tmp/lazygit-edit-done')
              
              -- Reopen lazygit using Snacks
              vim.schedule(function()
                Snacks.lazygit()
              end)
            end,
          })
        end)
      end
      
      checking = false
    end
    
    -- Start monitoring when lazygit is opened
    vim.api.nvim_create_autocmd('TermOpen', {
      group = group,
      pattern = '*lazygit*',
      callback = function()
        -- Clear any existing file
        vim.fn.writefile({}, '/tmp/lazygit-edit-file')
        
        -- Start checking every 100ms
        timer:start(100, 100, vim.schedule_wrap(check_and_open_file))
      end,
    })
    
    -- Stop monitoring when lazygit is closed
    vim.api.nvim_create_autocmd('TermClose', {
      group = group,
      pattern = '*lazygit*',
      callback = function()
        timer:stop()
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
