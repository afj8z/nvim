local function load_leap()
	local leap = require("leap")

	vim.keymap.set({ "n", "x", "o" }, "s", function()
		leap.leap({})
	end)

	vim.keymap.set({ "n", "x", "o" }, "S", function()
		leap.leap({ backward = true })
	end)
end

return {
	name = "leap",
	src = { src = "https://codeberg.org/andyg/leap.nvim" },
	load = load_leap,
}
