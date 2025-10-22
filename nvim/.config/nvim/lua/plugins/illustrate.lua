vim.pack.add({
	{ src = "https://github.com/rpapallas/illustrate.nvim.git" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim.git" },
	{ src = "https://github.com/nvim-lua/plenary.nvim.git" },
})

require("illustrate")

local illustrate = require("illustrate")
local illustrate_finder = require("illustrate.finder")
vim.keymap.set("n", "<leader>is", function()
	illustrate.create_and_open_svg()
end, {})
vim.keymap.set("n", "<leader>ia", function()
	illustrate.create_and_open_ai()
end, {})
vim.keymap.set("n", "<leader>io", function()
	illustrate.open_under_cursor()
end, {})
vim.keymap.set("n", "<leader>if", function()
	illustrate_finder.search_and_open()
end, {})
vim.keymap.set("n", "<leader>ic", function()
	illustrate_finder.search_create_copy_and_open()
end, {})
