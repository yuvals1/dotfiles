return {
  "mbbill/undotree",
  cmd = { "UndotreeToggle", "UndotreePersistUndo" },
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
  },
  config = function()
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_ShortIndicators = 1
    vim.g.undotree_SplitWidth = 24
    vim.g.undotree_DiffpanelHeight = 10
    vim.g.undotree_SetFocusWhenToggle = 1
    
    -- Enable persistent undo
    if vim.fn.has("persistent_undo") == 1 then
      local target_path = vim.fn.expand("~/.undodir")
      
      -- Create the directory if it doesn't exist
      if vim.fn.isdirectory(target_path) == 0 then
        vim.fn.mkdir(target_path, "p", 0700)
      end
      
      vim.opt.undodir = target_path
      vim.opt.undofile = true
    end
  end,
}