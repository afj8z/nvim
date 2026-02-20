local utils = require("ajf.utils")

local neogit_loaded = false
local function load_and_remap_neogit()
	if neogit_loaded then
		return
	end
	neogit_loaded = true
	vim.pack.add({
		{ src = "https://github.com/NeogitOrg/neogit.git" },
		{ src = "https://github.com/nvim-telescope/telescope.nvim" },
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
	})
end

utils.command_stub("Neogit", load_and_remap_neogit)
