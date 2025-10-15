local caps = require("lspcaps").caps

return {
	cmd = { "stata-language-server" }, -- Path to the server executable
	filetypes = { "stata" }, -- Filetypes to associate with the server
	root_markers = { ".git" },
	single_file_support = true,
	settings = {
		stata = {
			setMaxLineLength = 70, -- Example: Set max line length
			setIndentSpace = 4, -- Example: Set indentation spaces
			enableCompletion = true, -- Enable autocompletion
			enableDocstring = true, -- Enable hover documentation
			enableStyleChecking = true, -- Enable style checking
			enableFormatting = true, -- Enable formatting
		},
	},
	capabilities = caps,
}
