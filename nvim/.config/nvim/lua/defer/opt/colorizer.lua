local function load_colorizer()
	local colorizer = require("colorizer")

	colorizer.setup({
		options = {
			parsers = {
				hex = {
					default = true, -- default value for unset format keys (see above)
					rgb = true, -- #RGB (3-digit)
					rgba = true, -- #RGBA (4-digit)
					rrggbb = true, -- #RRGGBB (6-digit)
					rrggbbaa = true, -- #RRGGBBAA (8-digit)
					hash_aarrggbb = true, -- #AARRGGBB (QML-style, alpha first)
					aarrggbb = true, -- 0xAARRGGBB
					no_hash = true, -- hex without '#' at word boundaries
				},
			},
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
		"c",
		"cpp",
	},
	load = load_colorizer,
	cmds = "ColorizerAttachToBuffer",
}
