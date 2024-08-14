return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
				layout_strategy = "vertical",
				layout_config = {
					vertical = {
						width = 0.8,
						height = 0.9,
						preview_height = 0.5,
						preview_cutoff = 0, -- Always show preview
					},
				},
				sorting_strategy = "ascending",
				winblend = 0,
			},
			pickers = {
				find_files = {
					hidden = true,
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
				live_grep = {
					additional_args = function()
						return { "--hidden" }
					end,
				},
			},
		})
		telescope.load_extension("fzf")

		local keymap = vim.keymap
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fd", "<cmd>Telescope oldfiles<cr><Esc>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr><Esc>", { desc = "Find todos" })
	end,
}
