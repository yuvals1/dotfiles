return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('tokyonight').setup {
      -- Choose between "storm", "moon", "night", and "day"
      style = 'storm',
      light_style = 'day',
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = 'dark',
        floats = 'dark',
      },
      sidebars = { 'qf', 'help' },
      day_brightness = 0.3,
      dim_inactive = false,
      lualine_bold = false,

      -- Remove the on_colors and on_highlights functions if you don't need them
      -- on_colors = function(colors) end,
      -- on_highlights = function(highlights, colors) end,

      -- Plugin integrations
      plugins = {
        cmp = true,
        gitsigns = true,
        nvim_tree = true,
        treesitter = true,
        notify = false,
        mini = true,
      },
    }

    vim.cmd [[colorscheme tokyonight]]
  end,
}
