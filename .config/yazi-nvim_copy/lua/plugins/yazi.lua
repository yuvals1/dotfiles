return {
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
}
