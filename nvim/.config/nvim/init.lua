vim.loader.enable()
-- variable settings for uniform style between plugins
local settings = {
	theme = "ever",
	-- border = "╭, ─,╮,│,╯,─,╰,│",
	border = "solid",
	symbols = {
		error = "E",
		warn = "W",
		info = "I",
		hint = "H",
	},
}

-- cache the settings table
require("ajf.utils").set_settings(settings)

require("ajf.mylsp")

-- modular config
require("config")
require("plugins")
require("ajf.colors")
