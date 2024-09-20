return {
  'otavioschwanck/arrow.nvim',
  opts = {
    show_icons = true,
    always_show_path = false,
    separate_by_branch = false,
    hide_handbook = false,
    save_path = function()
      return vim.fn.stdpath 'cache' .. '/arrow'
    end,
    mappings = {
      edit = 'e',
      delete_mode = 'd',
      clear_all_items = 'C',
      toggle = 's',
      open_vertical = 'v',
      open_horizontal = '-',
      quit = 'q',
      remove = 'x',
      next_item = 'l',
      prev_item = 'h',
    },
    custom_actions = {
      open = function(target_file_name, current_file_name) end,
      split_vertical = function(target_file_name, current_file_name) end,
      split_horizontal = function(target_file_name, current_file_name) end,
    },
    window = {
      width = 'auto',
      height = 'auto',
      row = 'auto',
      col = 'auto',
      border = 'double',
    },
    per_buffer_config = {
      lines = 4,
      sort_automatically = true,
      satellite = {
        enable = false,
        overlap = true,
        priority = 1000,
      },
      zindex = 10,
      treesitter_context = nil,
    },
    separate_save_and_remove = false,
    leader_key = ';',
    buffer_leader_key = 'm',
    save_key = 'cwd',
    global_bookmarks = false,
    index_keys = '123456789zxcbnmZXVBNM,afghjklAFGHJKLwrtyuiopWRTYUIOP',
    full_path_list = { 'update_stuff' },
  },
  config = function(_, opts)
    require('arrow').setup(opts)

    -- Additional keymaps for navigation
    -- vim.keymap.set('n', 'H', require('arrow.persist').previous)
    -- vim.keymap.set('n', 'L', require('arrow.persist').next)
    -- vim.keymap.set('n', '<C-s>', require('arrow.persist').toggle)

    -- Keymaps for buffer bookmarks (assuming these functions exist)
    vim.keymap.set('n', 'mj', function()
      require('arrow.bufferline').next()
    end)
    vim.keymap.set('n', 'mk', function()
      require('arrow.bufferline').previous()
    end)
  end,
}
