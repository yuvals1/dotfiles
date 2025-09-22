return {
  {
    'ojroques/vim-oscyank',
    branch = 'main',
    config = function()
      -- Configure vim-oscyank
      vim.g.oscyank_max_length = 0 -- maximum length of a selection (0 means no limit)
      vim.g.oscyank_silent = false -- set to true to disable message on successful copy
      vim.g.oscyank_trim = false -- set to true to trim surrounding whitespaces before copy

      -- Set up keymaps
      vim.keymap.set('n', '<leader>c', '<Plug>OSCYankOperator', { desc = 'OSC Yank Operator' })
      -- vim.keymap.set('n', '<leader>cc', '<leader>c_', { remap = true, desc = 'OSC Yank Line' })
      vim.keymap.set('v', '<leader>c', '<Plug>OSCYankVisual', { desc = 'OSC Yank Visual' })

      -- Set up autocmd for automatic copying (optional)
      vim.api.nvim_create_autocmd('TextYankPost', {
        callback = function()
          if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
            vim.fn['OSCYankRegister'] '"'
          end
        end,
      })
    end,
  },
  {
    'ojroques/nvim-osc52',
    lazy = false,
    config = function()
      local osc52 = require 'osc52'

      osc52.setup {
        max_length = 0,
        silent = true,
        trim = false,
      }

      local function copy(lines, regtype)
        regtype = regtype or 'v'
        local data = table.concat(lines, '\n')
        if regtype == 'V' then
          data = data .. '\n'
        end
        osc52.copy(data)
        vim.fn.setreg('+', data, regtype)
        vim.fn.setreg('*', data, regtype)
      end

      local function paste()
        return vim.fn.getreg('+', 1, true), vim.fn.getregtype('+')
      end

      vim.g.clipboard = {
        name = 'osc52',
        copy = {
          ['+'] = copy,
          ['*'] = copy,
        },
        paste = {
          ['+'] = paste,
          ['*'] = paste,
        },
      }
    end,
  },
}
