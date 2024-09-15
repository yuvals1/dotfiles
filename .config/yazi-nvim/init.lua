-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins
require("lazy").setup({
	{
		"mikavilpas/yazi.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- optional
		},
		opts = {
			-- Example configuration (you can customize this)
			open_for_directories = false,
			floating_window_scaling_factor = 0.9,
		},
		keys = {
			-- Example keymapping
			{ "<leader>y", "<cmd>Yazi<cr>", desc = "Open Yazi" },
		},
	},
})

-- Set leader key (optional, but recommended for the default keymapping)
vim.g.mapleader = " "
