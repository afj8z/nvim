local function load_colorizer()
	local colorizer = require("colorizer")

	colorizer.setup({
		user_default_options = {
			names = false,
			css = true,
		},
	})

	-- colorizer.attach_to_buffer(args.buf)
end

return {
	name = "colorizer",
	src = "https://github.com/catgoose/nvim-colorizer.lua",
	ft = {
		"css",
		"html",
		"javascript",
		"lua",
		"scss",
		"json",
		"toml",
		"typst",
		"kitty",
	},
	load = load_colorizer,
	cmds = "ColorizerAttachToBuffer",
}
