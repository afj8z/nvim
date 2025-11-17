local utils = require("utils")

utils.lazy_on_filetype("Colorizer", {
	"css",
	"html",
	"javascript",
	"lua",
	"scss",
}, function()
	vim.pack.add({
		{ src = "https://github.com/catgoose/nvim-colorizer.lua.git" },
	})
	require("colorizer").setup({
		user_default_options = {
			names = false,
			css = true,
		},
	})
end)
