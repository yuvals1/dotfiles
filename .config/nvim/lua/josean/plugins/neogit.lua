return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration
		-- Only one of these is needed, not both.
		"nvim-telescope/telescope.nvim", -- optional
		"ibhagwan/fzf-lua", -- optional
	},
	config = function()
		local neogit = require("neogit")
		neogit.setup({})
		-- Keymaps
		vim.keymap.set("n", "<leader>ng", function()
			neogit.open()
		end, { desc = "Open Neogit" })
		vim.keymap.set("n", "<leader>nd", function()
			vim.cmd("DiffviewOpen")
		end, { desc = "Open Diffview" })
		-- Updated keymap to close both Neogit and Diffview
		vim.keymap.set("n", "<leader>nx", function()
			if vim.bo.filetype == "DiffviewFiles" then
				vim.cmd("DiffviewClose")
			else
				neogit.close()
			end
		end, { desc = "Close Neogit or Diffview" })
	end,
}
