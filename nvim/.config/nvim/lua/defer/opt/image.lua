local utils = require("defer")

local controller_load_fn = utils.create_toggle_controller("Image", {
	load = function()
		require("image").setup({
			backend = "kitty",
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
	cmds = "Image",
	load = controller_load_fn,
}
