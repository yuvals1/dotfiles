return {
  'stevearc/overseer.nvim',
  lazy = true,
  cmd = {
    'OverseerRun',
    'OverseerToggle',
    'OverseerOpen',
    'OverseerClose',
    'OverseerLoadBundle',
    'OverseerSaveBundle',
    'OverseerDeleteBundle',
    'OverseerRunCmd',
    'OverseerQuickAction',
    'OverseerTaskAction',
  },
  keys = {
    -- You can add custom keybindings here if desired
    -- { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Toggle Overseer" },
    -- { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run Overseer Task" },
  },
  opts = {
    -- Your Overseer configuration options go here
    -- For example:
    -- task_list = {
    --   direction = "bottom",
    --   min_height = 25,
    --   max_height = 25,
    --   default_detail = 1,
    -- },
  },
}
