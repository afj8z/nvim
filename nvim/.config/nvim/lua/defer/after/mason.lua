local function load_mason()
	require("mason").setup()

	require("mason-lspconfig").setup({})

	require("mason-tool-installer").setup({
		ensure_installed = {
			"clangd",
			"clang-format",
			"rust-analyzer",
			"basedpyright",
			"lua_ls",
			"tombi",
			"biome",
			"rstcheck",
			"tinymist",
			"typstyle",
			"emmet_ls",
			"bashls",
			"prettierd",
			"black",
			"ruff",
			"eslint_d",
			"shellcheck",
			"stylua",
			"prettier",
			"json-lsp",
			"marksman",
			"ts_ls",
			"joker",
			"sqls",
			"r-languageserver",
			"air",
		},
	})
end

return {
	name = "mason",
	src = "https://github.com/mason-org/mason.nvim",
	load = load_mason,
	exts = {
		"https://github.com/mason-org/mason-lspconfig.nvim",
		"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	deps = {
		"lsp",
	},
}
