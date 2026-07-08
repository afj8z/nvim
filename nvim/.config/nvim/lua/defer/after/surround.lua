local function load_surround()
	local utils = require("ajf.utils")
	local nmap = utils.nmap

	require("mini.surround").setup({
		mappings = {
			add = "gsa",
			delete = "gsd",
			find = "gsf",
			find_left = "gsF",
			highlight = "gsh",
			replace = "gsr",
		},
		custom_surroundings = {
			m = {
				input = { "m" },
				output = { left = "$", right = "$" },
			},
			c = {
				input = { "c" },
				output = { left = "{", right = "}" },
			},

			B = {
				input = { "B" },
				output = { left = '("', right = '")' },
			},

			s = {
				input = { "s" },
				output = { left = "*", right = "*" },
			},
		},
	})
end
return {
	name = "mini-surround",
	src = { src = "https://github.com/nvim-mini/mini.surround.git" },
	load = load_surround,
}
