-- Place this file in your Neovim config directory (usually ~/.config/nvim/lua/plugins/)

return {
  {
    'tpope/vim-dadbod',
    lazy = true,
    dependencies = {
      {
        'kristijanhusak/vim-dadbod-ui',
        lazy = true,
      },
      {
        'kristijanhusak/vim-dadbod-completion',
        ft = { 'sql', 'mysql', 'plsql' },
        lazy = true,
      },
    },
    cmd = {
      'DB',
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Setup UI and configuration options
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1

      -- Save DBUI sessions to a specific location
      vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'

      -- Set up auto-completion
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sql', 'mysql', 'plsql' },
        callback = function()
          require('cmp').setup.buffer {
            sources = { {
              name = 'vim-dadbod-completion',
            } },
          }
        end,
      })

      -- Execute query when the buffer is saved
      vim.g.db_ui_execute_on_save = 1

      -- Set win position to right
      vim.g.db_ui_win_position = 'right'

      -- Increase the drawer width
      vim.g.db_ui_winwidth = 60

      -- Disable info notifications after query execution
      vim.g.db_ui_disable_info_notifications = 1
    end,
    config = function()
      -- Add custom key mappings or additional configuration if needed
      -- This will run when the plugin is loaded
    end,
  },
}
