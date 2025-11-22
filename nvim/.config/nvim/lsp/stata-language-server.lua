local caps = require("ajf.lspcaps").caps

return {
	cmd = { "stata-language-server" },
	filetypes = { "stata" }, -- Filetypes to associate with the server
	root_markers = { ".git" },
	single_file_support = true,
	settings = {
		stata = {
			setMaxLineLength = 70,
			setIndentSpace = 4,
			enableCompletion = true,
			enableDocstring = true,
			enableStyleChecking = true,
			enableFormatting = true,
		},
	},
	capabilities = caps,
}
