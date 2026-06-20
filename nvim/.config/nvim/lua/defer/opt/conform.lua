local function load_conform()
	require("conform").setup({
		log_level = vim.log.levels.DEBUG,
		format_on_save = {
			timeout_ms = 1000,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			typst = { "typstyle" },
			python = { "ruff", "black" },
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = {
				"prettierd",
				"prettier",
				stop_after_first = true,
			},
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = {
				"prettierd",
				"prettier",
				stop_after_first = true,
			},
			json = { "prettier", stop_after_first = true },
			shellscript = { "prettier", stop_after_first = true },
			markdown = { "prettier", stop_after_first = true },
			stata = { "statafmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			kanata = { "kbdfmt" },
			r = { "air" },
			go = { "gofumpt", "golines" },
		},
		formatters = {
			golines = {
				command = "golines",
				args = { "-m", "80", "-t", "6", "--shorten-comments" },
				stdin = true,
			},

			kbdmft = {
				command = "kbdfmt",
				args = { "--write", "%" },
				stdin = true,
			},
			statafmt = {
				command = "statafmt",
				args = { "--width", "40", "--cont-indent", "2" },
				stdin = true,
			},
			typstyle = {
				command = "typstyle",
				args = {
					"--line-width",
					"84",
					"-t",
					"4",
				},
				stdin = true,
			},
			["clang-format"] = {
				command = "clang-format",
				args = {
					"--style=file",
					"--fallback-style=GNU",
				},
			},
			-- prettier = {
			-- 	args = { "--config-precedence", "prefer-file" },
			-- },
		},
	})

	vim.api.nvim_create_user_command("ConformInfo", function()
		require("conform.health").show_window()
	end, { desc = "Show information about Conform formatters" })
end

return {
	name = "conform",
	src = "https://github.com/stevearc/conform.nvim",
	ft = {
		"typst",
		"python",
		"lua",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"markdown",
		"stata",
		"sh",
		"zsh",
		"bash",
		"shellscript",
		"kanata",
		"c",
		"cpp",
		"go",
	},
	load = load_conform,
}
