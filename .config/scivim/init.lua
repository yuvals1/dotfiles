--[[
-- The Ultimate SciVim
--]]
-- require("SciVim.configs.options")
-- require("SciVim.configs.keymaps")
-- require("SciVim.configs.autocmds")
-- require("SciVim.configs.lazy")
-- vim.cmd([[colorscheme nightfly]])
-- require("SciVim.configs.init")

--[[
-- The Ultimate SciVim
--]]
--[[
-- The Ultimate SciVim
--]]
local nvim_config_path = vim.fn.expand("~/.config/nvim-sci")
vim.opt.runtimepath:prepend(nvim_config_path)
package.path = package.path .. ";" .. nvim_config_path .. "/lua/?.lua"

local function load_module(module_name)
	local ok, module = pcall(require, module_name)
	if not ok then
		print("Error loading module: " .. module_name)
		print(module) -- This will print the error message
	end
end

load_module("SciVim.configs.options")
load_module("SciVim.configs.keymaps")
load_module("SciVim.configs.autocmds")
load_module("SciVim.configs.lazy")
vim.cmd([[colorscheme nightfly]])
load_module("SciVim.configs.init")
