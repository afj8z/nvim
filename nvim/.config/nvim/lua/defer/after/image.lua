local utils = require("defer")

local controller_load_fn = utils.create_toggle_controller("Image", {
	load = function()
		require("image").setup({
			backend = "sixel",
		})
	end,

	enable = function()
		vim.cmd("lua require('image').enable()")
	end,

	disable = function()
		vim.cmd("lua require('image').disable()")
	end,
})

vim.keymap.set("n", "<leader>i", ":ImageToggle<CR>", { silent = true })

return {
	name = "image",
	src = "https://github.com/3rd/image.nvim",
	load = controller_load_fn,
}
