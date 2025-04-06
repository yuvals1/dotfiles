return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    require('noice').setup {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      -- Disable notifications
      notify = {
        enabled = false,
      },
      messages = {
        enabled = false, -- disable the notifications that appear in the bottom right
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            kind = '',
            find = 'written',
          },
          opts = { skip = true },
        },
      },
      cmdline = {
        enabled = true, -- enables the Noice cmdline UI
        view = 'cmdline_popup', -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
      },
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = '50%',
          },
          size = {
            width = 60,
            height = 'auto',
          },
        },
        popupmenu = {
          relative = 'editor',
          position = {
            row = 8,
            col = '50%',
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = 'rounded',
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
          },
        },
      },
    }
    vim.keymap.set('n', '<leader>nd', function()
      require('noice').cmd 'dismiss'
    end, { silent = true, desc = 'Dismiss Noice notifications' })
    vim.keymap.set('n', '<C-space>', function()
      require('noice').cmd 'dismiss'
    end, { silent = true, desc = 'Dismiss Noice notifications' })
  end,
}
