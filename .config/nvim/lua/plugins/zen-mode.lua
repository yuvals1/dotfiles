return {
  "folke/zen-mode.nvim",
  cmd = { "ZenMode" },
  keys = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
  },
  opts = {
    window = {
      backdrop = 0.95,
      width = 90,
      height = 1,
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        cursorline = false,
        cursorcolumn = false,
        foldcolumn = "0",
        list = false,
      },
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false,
        showcmd = false,
        laststatus = 0,
      },
      twilight = { enabled = false },
      gitsigns = { enabled = false },
      tmux = { enabled = false },
    },
    on_open = function(win)
      -- Save original wrap settings
      vim.g.zen_mode_original_wrap = vim.opt.wrap:get()
      vim.g.zen_mode_original_linebreak = vim.opt.linebreak:get()
      -- Enable wrap for zen mode
      vim.opt.wrap = true
      vim.opt.linebreak = true
    end,
    on_close = function()
      -- Restore original wrap settings
      vim.opt.wrap = vim.g.zen_mode_original_wrap
      vim.opt.linebreak = vim.g.zen_mode_original_linebreak
    end,
  },
}