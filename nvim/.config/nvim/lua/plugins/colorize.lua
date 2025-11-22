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
}, function(args)
	vim.pack.add({
		{
			src = "https://github.com/catgoose/nvim-colorizer.lua",
		},
	})

	local colorizer = require("colorizer")

	colorizer.setup({
		user_default_options = {
			names = false,
			css = true,
		},
	})

	colorizer.attach_to_buffer(args.buf)
end)
