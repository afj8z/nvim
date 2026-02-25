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

local function load_leetcode()
	vim.cmd("TSUpdate html")

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

return {
	name = "leetcode",
	src = "https://github.com/kawre/leetcode.nvim.git",
	load = load_leetcode,
	cmds = "Leet",
	deps = "telescope",
	libs = "plenary",
}
