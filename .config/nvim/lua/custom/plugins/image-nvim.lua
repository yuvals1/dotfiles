return {
  '3rd/image.nvim',
  cond = function()
    return vim.fn.has 'mac' == 1
  end,
  config = function()
    local image = require 'image'
    image.setup {
      backend = 'kitty',
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { 'markdown' },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
    }
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}
