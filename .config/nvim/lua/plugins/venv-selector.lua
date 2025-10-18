return {
  'linux-cultist/venv-selector.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'mfussenegger/nvim-dap-python',
  },
  opts = {
    -- Your options go here
    auto_refresh = false,
    search_venv_managers = true,
    search_workspace = true,
    dap_enabled = true, -- Enable debugger support
    parents = 2, -- Number of parent directories to search
    name = { 'venv', '.venv' }, -- Multiple names to search for
    notify_user_on_activate = true,
  },
  event = 'VeryLazy', -- Load the plugin when needed
  keys = {
    -- Keymap to open VenvSelector to pick a venv
    { '<leader>vs', '<cmd>VenvSelect<cr>', desc = 'Select VirtualEnv' },
    -- Keymap to retrieve the venv from cache
    { '<leader>vc', '<cmd>VenvSelectCached<cr>', desc = 'Select Cached VirtualEnv' },
  },
}
