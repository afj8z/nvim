local utils = require("ajf.utils")

local ttyper_loaded = false
local function load_and_remap_ttyper()
	if ttyper_loaded then
		return
	end
	ttyper_loaded = true

	vim.pack.add({
		{ src = "https://github.com/nvzone/typr.git" },
		{ src = "https://github.com/nvzone/volt.git" },
	})
end

utils.command_stub("Typr", load_and_remap_ttyper)
