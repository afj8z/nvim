local utils = require("ajf.utils")

utils.lazy_on_filetype("Colorizer", {
	"css",
	"html",
	"javascript",
	"lua",
	"scss",
	"json",
	"toml",
	"typst",
	"kitty",
}, function()
	vim.cmd("packadd nvim-colorizer.lua")
	require("colorizer").setup({
		user_default_options = {
			names = false,
			css = true,
		},
	})
end)
