local function load_nim()
	require("nIM").setup({
		enabled = { statusline = false },
		run_file = {
			keymap = "<leader>a",
		},
		redir = {
			keymaps = {
				expand_cmd = "<C-a>",
			},
		},
		statusline = {
			modules = {
				lsp = { use_conform = true, show_formatter = false },
				file = {
					path = {
						show = "name",
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
				mode = { markers = "" },
				diagnostics = { persist = { error = false, warn = false } },
				file_info = {
					show = {
						filetype = false,
						encoding = false,
						filesize = true,
						permissions = true,
					},
					permissions = { short = false },
					separator = "  ",
				},
			},
			order = {
				left = { "mode", "file", "file_info", "snippet" },
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
				browse_global = "<leader>xg",
				browse_local = "<leader>xc",
			},
		},
		projectfile = {
			keymaps = {
				find = "<leader>p",
			},
		},
	})
end

return {
	name = "nim",
	load = load_nim,
}
