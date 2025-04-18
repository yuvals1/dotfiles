return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
      lazy = true,
    },
    'AndreM222/copilot-lualine',
  },
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'diff', 'diagnostics' },
        --       lualine_c = {
        --         {
        --           'filename',
        --           path = 1,
        --           shorting_target = 40,
        --         },
        --       },
        lualine_x = {
          {
            'copilot',
            symbols = {
              status = {
                hl = {
                  enabled = '#50FA7B', -- Green for enabled/active
                  sleep = '#AEB7D0', -- Grey for sleep/inactive
                  disabled = '#6272A4', -- Blue-grey for disabled
                  warning = '#FFB86C', -- Orange for warning
                  unknown = '#FF5555', -- Red for unknown
                },
              },
              spinners = require('copilot-lualine.spinners').dots,
              spinner_color = '#6272A4',
            },
            show_colors = true,
            show_loading = true,
          },
          'filetype',
        },
        lualine_y = { 'progress' },
        -- lualine_z = {
        --         {
        --           function()
        --             return tostring(vim.fn.line '$')
        --           end,
        --           icon = '☰',
        --         },
        --       },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        -- lualine_c = {
        --         {
        --           'filename',
        --           path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
        --           shorting_target = 40, -- Shortens path to leave 40 spaces in the window
        --         },
        --       },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    }
  end,
}
