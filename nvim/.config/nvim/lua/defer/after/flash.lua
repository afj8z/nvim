local function load_flash()
	require("flash").setup({

		jump = {
			pos = "end",
		},
		modes = {
			char = {
				jump_labels = function(motion)
					return vim.v.count == 0 and motion:find("[ftFT]")
				end,
			},
		},
	})
end

return {
	name = "flash",
	src = { src = "https://github.com/folke/flash.nvim.git" },
	load = load_flash,
}
