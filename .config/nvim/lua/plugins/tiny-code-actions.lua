return {
  'rachartier/tiny-code-action.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope.nvim' },
  },
  event = 'LspAttach',
  config = function()
    require('tiny-code-action').setup {
      backend = 'delta', -- Set the backend to delta
      backend_opts = {
        delta = {
          -- Optionally remove header lines if they're too large
          header_lines_to_remove = 4,
          -- Customize delta arguments as needed
          args = {
            '--line-numbers',
            -- Add any other delta arguments you prefer
          },
        },
      },
      -- Other options remain the same
      telescope_opts = {
        layout_strategy = 'vertical',
        layout_config = {
          width = 0.7,
          height = 0.9,
          preview_cutoff = 1,
          preview_height = function(_, _, max_lines)
            local h = math.floor(max_lines * 0.5)
            return math.max(h, 10)
          end,
        },
      },
      -- You can customize the signs if you want, or leave them as default
    }
  end,
}
