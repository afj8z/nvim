local function load_flash()
	require("flash").setup({
		modes = {
			char = {
				jump_labels = true,

				jump = {
					autojump = true,
				},
			},
		},
		jump = {
			autojump = true,
		},
	})
end
return {
	name = "flash",
	src = { src = "https://github.com/folke/flash.nvim.git" },
	load = load_flash,
}
