local utils = require("defer")

local controller_load_fn = utils.create_toggle_controller("Image", {
	load = function()
		require("image").setup({
			backend = "ueberzug",
		})
	end,

	enable = function()
		vim.cmd("lua require('image').enable()") -- enable the plugin
	end,

	disable = function()
		vim.cmd("lua require('image').disable()") -- disable the plugin
	end,
})

return {
	name = "image",
	src = "https://github.com/3rd/image.nvim",
	load = controller_load_fn,
}
