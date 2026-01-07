local utils = require("ajf.utils")

local function is_image_loaded()
	local plug = vim.pack.get({ "image.nvim" })
	local dta = table.remove(plug, 1)
	if dta.active then
		if not require("image").is_enabled() then
			require("image").enable()
		end
	else
		vim.cmd("ImageToggle")
	end
end

local leetcode_loaded = false
local function load_and_remap_leetcode()
	if leetcode_loaded then
		return
	end
	leetcode_loaded = true
	vim.cmd("TSUpdate html")

	vim.pack.add({
		{ src = "https://github.com/kawre/leetcode.nvim.git" },
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
		{ src = "https://github.com/MunifTanjim/nui.nvim" },
		{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	})

	is_image_loaded()

	require("leetcode").setup({
		lang = "python3",
		theme = {
			["alt"] = {
				link = "Constant",
			},
			["normal"] = {
				link = "Normal",
			},
		},
		image_support = true,
	})
end

utils.command_stub("Leet", load_and_remap_leetcode)
