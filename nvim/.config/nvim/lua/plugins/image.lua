local utils = require("ajf.utils")

local controller_load_fn = utils.create_toggle_controller("Image", {
	load = function()
		vim.pack.add({
			{ src = "https://github.com/3rd/image.nvim" },
		})
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

utils.command_stub("Image", controller_load_fn)
