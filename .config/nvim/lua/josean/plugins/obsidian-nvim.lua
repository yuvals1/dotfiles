return {
	"epwalsh/obsidian.nvim",
	version = "*",
	event = "VimEnter", -- Load the plugin on startup
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{ "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian note" },
		-- { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open Obsidian" },
		{ "<leader>oo", "<cmd>ObsidianSearch<cr>", desc = "Obsidian Search" },
		{ "<leader>os", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch" },
		{ "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Follow Link" },
		{ "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show Backlinks" },
		{ "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
		{ "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today template" },
	},
	opts = {
		workspaces = {
			{
				name = "yuval",
				path = "~/vaults/yuval",
			},
		},
		templates = {
			subdir = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
		},
		note_id_func = function(title)
			-- Create note IDs with a timestamp and the title as a suffix
			local suffix = ""
			if title ~= nil then
				-- If title is given, transform it into a valid file name
				suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			else
				-- If title is nil, just add 4 random uppercase letters to the suffix
				for _ = 1, 4 do
					suffix = suffix .. string.char(math.random(65, 90))
				end
			end
			return tostring(os.time()) .. "-" .. suffix
		end,
		mappings = {
			-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			["<M-x>"] = {
				action = function()
					local obsidian = require("obsidian")
					obsidian.util.toggle_checkbox()
					-- Use vim.schedule to ensure the toggle has completed before moving the cursor
					vim.schedule(function()
						-- Move to the end of the line and enter insert mode
						-- vim.cmd("normal! A")
						vim.cmd("normal! $")
						-- vim.cmd("startinsert!")
					end)
				end,
				opts = { buffer = true },
			},
			-- Smart action depending on context, either follow link or toggle checkbox.
			-- ["<cr>"] = {
			-- 	action = function()
			-- 		return require("obsidian").util.smart_action()
			-- 	end,
			-- 	opts = { buffer = true, expr = true },
			-- },
		},
	},
}
