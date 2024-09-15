-- Set the exact path to the yazi-nvim configuration
local yazi_nvim_path = "/Users/yuvals1/dotfiles/.config/yazi-nvim_copy"

-- Add the custom path to Neovim's runtime path
vim.opt.runtimepath:prepend(yazi_nvim_path)

-- Add the custom path to Lua's package path
package.path = package.path .. ";" .. yazi_nvim_path .. "/lua/?.lua"

-- Function to safely load modules
local function load_module(module_name)
	local ok, module = pcall(require, module_name)
	if not ok then
		print("Error loading module: " .. module_name)
		print(module) -- This will print the error message
	end
end

-- Attempt to load the main configuration
load_module("config")

-- If the above fails, try loading directly with dofile
if not package.loaded.config then
	local config_path = yazi_nvim_path .. "/lua/config.lua"
	if vim.fn.filereadable(config_path) == 1 then
		dofile(config_path)
	else
		print("Config file not found at: " .. config_path)
	end
end
