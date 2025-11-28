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
	statusline = {
		modules = {
			lsp = {
				use_conform = true,
				show_formatter = true,
			},
		},
		order = {
			left = { "file", "git_branch" },
			-- center = {},
			right = {
				"lsp",
				"diagnostics",
				"position",
			},
		},

		icons = {
			diagnostics = {
				ERROR = "E",
				WARN = "W",
				HINT = "H",
				INFO = "I",
			},
		},
	},
})
