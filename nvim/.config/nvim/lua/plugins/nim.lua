-- plugin is located in runtimepath, under active development
require("nIM").setup({
	run_file = {
		keymap = "<leader>a",
	},
	redir = {
		keymaps = {
			-- "expand_cmd" captures the current command line and redirects output.
			expand_cmd = "<C-v>",
		},
	},
})
