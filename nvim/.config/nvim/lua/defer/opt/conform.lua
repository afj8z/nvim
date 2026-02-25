local function load_conform()
	require("conform").setup({
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
			json = { "prettierd", "prettier", stop_after_first = true },
			shellscript = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			stata = { "statafmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			-- TODO: formatter for kanata (ft=kbd)
			-- WARN: something
		},
		formatters = {
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
				args = "--style='{BasedOnStyle: GNU, IndentWidth: 4}'",
			},
			prettier = {
				args = { "--config-precedence", "prefer-file" },
			},
		},
	})
	-- command defined in plugin/init.lua
	vim.api.nvim_create_user_command("ConformInfo", function()
		require("conform.health").show_window()
	end, { desc = "Show information about Conform formatters" })

	-- Allows eslint + prettier to work in tandem
	-- Kept inside the callback so it only activates when formatting is actually needed
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
		"kbd",
		"c",
		"cpp",
	},
	load = load_conform,
}
