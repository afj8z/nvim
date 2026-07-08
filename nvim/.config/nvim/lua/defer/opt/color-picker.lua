local function load_colorpicker()
	local hl = require("oklch-color-picker")
	hl.setup({
		patterns = {
			typst_rgba = {
				ft = { "typst" },
				-- format = "hex",
				custom_parse = function(match)
					return hl.highlight.parse("#" .. match)
				end,
				'rgb%("()#?%x%x%x+%f[%W]()"%)',
			},
		},
	})

	vim.keymap.set("n", "<leader>v", function()
		require("oklch-color-picker").pick_under_cursor()
	end, { desc = "Color pick under cursor" })
end
return {
	name = "colorpicker",
	src = "https://github.com/eero-lehtinen/oklch-color-picker.nvim.git",
	ft = {
		"css",
		"html",
		"javascript",
		"lua",
		"scss",
		"json",
		"jsonc",
		"toml",
		"typst",
		"kitty",
		"c",
		"cpp",
	},
	load = load_colorpicker,
	cmds = "ColorPickOklch",
}
