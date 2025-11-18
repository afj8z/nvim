vim.loader.enable()
-- variable settings for uniform style between plugins
local settings = {
	theme = "ever",
	border = "single",
	symbols = {
		error = "E",
		warn = "W",
		info = "I",
		hint = "H",
	},
}

-- cache the settings table
require("utils").set_settings(settings)

require("mylsp")

-- modular config
require("ajf")
require("config")
require("plugins")
require("colors")
