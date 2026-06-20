local function load_zeal()
	local zeal = require("zeal")
	zeal.setup({})

	vim.keymap.set("n", "<leader>sa", function()
		require("zeal").search()
	end, { desc = "Search Zeal Docs" })

	-- vim.keymap.set("n", "<leader>k", function()
	-- 	local query = vim.fn.expand("<cword>")
	-- 	require("zeal").search_ft(query)
	-- end, { desc = "Search Zeal Docs by ft for cword" })
end

return {
	name = "zeal",
	src = "https://github.com/paradoxical-dev/zeal.nvim.git",
	load = load_zeal,
	keys = {
		{ "n", "<leader>sa", desc = "Search Zeal Docs" },
		-- { "n", "<leader>k", desc = "Search Zeal Docs by ft for cword" },
	},
	cmds = {
		"Zeal",
	},
}
