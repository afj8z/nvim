local function load_nim()
	require("nIM").setup({
		run_file = {
			keymap = "<leader>a",
		},
		redir = {
			keymaps = {
				-- "expand_cmd" captures the current command line and redirects output.
				expand_cmd = "<C-a>",
			},
		},
		statusline = {
			modules = {
				lsp = {
					use_conform = true,
					show_formatter = true,
				},
				file = {
					path = {
						show = "full",
						envsub = {
							["/home/aidanfleming"] = "~",
							regex = {
								["arch%-dots/[^/]+/%.config/([^/]+)"] = "dots/.c/%1",
								["nvim/nvim/.config/nvim"] = "nvdots",
								["arch%-dots"] = "dots",
							},
						},
					},
				},
				mode = {
					name = "short",
					markers = "-",
				},
			},
			order = {
				left = { "mode", "file", "snippet" },
				center = {},
				right = { "lsp", "diagnostics", "position" },
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
		snipshot = {
			keymaps = {
				-- paste_recent = "<leader>xx", -- e.g. "<Leader>p"
				browse_global = "<leader>xg", -- e.g. "<Leader>pg"
				browse_local = "<leader>xl", -- e.g. "<Leader>pl"
			},
		},
		projectfile = {
			keymaps = {
				find = "<leader>h",
			},
		},
	})
end

return {
	name = "nim",
	load = load_nim,
}
