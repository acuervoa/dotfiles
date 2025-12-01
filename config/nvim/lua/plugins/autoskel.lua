-- lua/plugins/autoskel.lua
local env = require("config.env")

local autoskel_dir = "/home/acuervo/Workspace/autoskel.nvim"

if env.is_wsl then
	autoskel_dir = "/home/af601888/Workspace/autoskel.nvim"
end

return {
	{
		dir = autoskel_dir, 
		name = "autoskel.nvim",
		dev = true,

		config = function()
			require("autoskel").setup()
		end,
	},
}
