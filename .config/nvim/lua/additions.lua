-- my additions
local M = {}

function M.setup()
  vim.keymap.set('n', 'yaa', ':%y<CR>', { noremap = true, silent = true, desc = 'Yank entire file' })

  vim.g.image_magick_dir = '/opt/homebrew'
  --
  local home = os.getenv 'HOME'
  package.path = package.path .. ';' .. home .. '/.luarocks/share/lua/5.1/?.lua;' .. home .. '/.luarocks/share/lua/5.1/?/init.lua'
  package.cpath = package.cpath .. ';' .. home .. '/.luarocks/lib/lua/5.1/?.so'

  -- local image = require 'image'
  -- local old_render = image.get_images()[1].render
  -- image.get_images()[1].render = function(self)
  --   print 'Render called'
  --   print('Window:', self.window)
  --   print('Is window valid:', vim.api.nvim_win_is_valid(self.window))
  --   old_render(self)
  -- end
  --
  --
  -- Your existing init.lua content here...
  -- neotree as file explorer
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function(data)
      -- buffer is a directory
      local directory = vim.fn.isdirectory(data.file) == 1

      if not directory then
        return
      end

      -- change to the directory
      vim.cmd.cd(data.file)

      -- close the current buffer (default directory listing)
      vim.cmd.bdelete()

      -- open the tree
      -- require('neo-tree.command').execute { toggle = true, dir = data.file }
    end,
    desc = 'Open Neo-tree on startup with directory',
  })

  -- Optionally, you can add this to close Neovim if Neo-tree is the last window
  vim.api.nvim_create_autocmd('BufEnter', {
    nested = true,
    callback = function()
      if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == 'neo-tree' then
        vim.cmd 'quit'
      end
    end,
  })

  vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim311/bin/python3'

  -- Open PDF files with Preview
  vim.api.nvim_create_autocmd('BufReadCmd', {
    pattern = '*.pdf',
    callback = function()
      local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
      vim.cmd('silent !open -a Preview ' .. filename)
      vim.cmd 'bdelete'
    end,
  })

  -- Open image files with Preview
  vim.api.nvim_create_autocmd('BufReadCmd', {
    pattern = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' },
    callback = function()
      local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
      vim.cmd('silent !open -a Preview ' .. filename)
      vim.cmd 'bdelete'
    end,
  })

  -- Command to copy relative path
  vim.api.nvim_create_user_command('CopyRelPath', function()
    local relative_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
    vim.fn.setreg('+', relative_path)
    print('Relative path copied to clipboard: ' .. relative_path)
  end, {})

  -- Command to copy full path
  vim.api.nvim_create_user_command('CopyFullPath', function()
    local full_path = vim.fn.expand '%:p'
    vim.fn.setreg('+', full_path)
    print('Full path copied to clipboard: ' .. full_path)
  end, {})

  -- Command to copy parent folder path
  vim.api.nvim_create_user_command('CopyParentPath', function()
    local parent_path = vim.fn.fnamemodify(vim.fn.expand '%:p', ':h')
    vim.fn.setreg('+', parent_path)
    print('Parent folder path copied to clipboard: ' .. parent_path)
  end, {})

  -- Keymapping for CopyRelPath
  vim.api.nvim_set_keymap('n', '<leader>cr', ':CopyRelPath<CR>', { noremap = true, silent = true })

  -- Keymapping for CopyFullPath
  vim.api.nvim_set_keymap('n', '<leader>cf', ':CopyFullPath<CR>', { noremap = true, silent = true })

  -- Keymapping for CopyParentPath
  vim.api.nvim_set_keymap('n', '<leader>cp', ':CopyParentPath<CR>', { noremap = true, silent = true })

  -- fixing go to file not working when there are spaces in the path
  local function go_to_file()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local filepath

    -- Try to match a filepath pattern
    filepath = line:match '"([^"]+)"' or line:match "'([^']+)'" or line:match '`([^`]+)`'

    if not filepath then
      -- If no quotes found, try to extract path from current cursor position
      local left = line:sub(1, col):reverse():find '[^%w%./\\-_]'
      local right = line:sub(col + 1):find '[^%w%./\\-_]'
      left = left and col - left + 1 or 1
      right = right and col + right or #line
      filepath = line:sub(left, right)
    end

    if filepath then
      -- Expand the path (resolves '~' to home directory)
      filepath = vim.fn.expand(filepath)

      -- Check if the file exists
      if vim.fn.filereadable(filepath) == 1 then
        vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
      else
        print('File not found: ' .. filepath)
      end
    else
      print 'No file path found under cursor'
    end
  end

  -- Create a user command
  vim.api.nvim_create_user_command('GoToFile', go_to_file, {})

  -- Map the function to gf
  vim.api.nvim_set_keymap('n', 'gf', ':GoToFile<CR>', { noremap = true, silent = true })
end

return M
