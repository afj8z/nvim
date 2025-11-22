local utils = require("ajf.utils")

utils.lazy_on_filetype("Conform", {
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
}, function()
	vim.pack.add({
		{
			src = "https://github.com/stevearc/conform.nvim",
		},
	})

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
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			shellscript = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			stata = { "statafmt" },
		},
		formatters = {
			statafmt = {
				command = "statafmt",
				args = { "--width", "40", "--cont-indent", "2" },
				stdin = true,
			},
		},
	})
	-- command defined in plugin/init.lua
	vim.api.nvim_create_user_command("ConformInfo", function()
		require("conform.health").show_window()
	end, { desc = "Show information about Conform formatters" })

	-- Allows eslint + prettier to work in tandem
	-- Kept inside the callback so it only activates when formatting is actually needed
	vim.api.nvim_create_autocmd("BufWritePre", {
		callback = function()
			vim.lsp.buf.format()
		end,
	})
end)
