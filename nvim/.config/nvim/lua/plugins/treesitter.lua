vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"rust",
		"svelte",
		"rst",
		"typescript",
		"javascript",
		"bash",
		"css",
		"html",
		"json",
		"lua",
		"markdown",
		"regex",
		"markdown_inline",
		"tsx",
		"vim",
		"vimdoc",
		"luadoc",
		"python",
		"yaml",
		"kanata",
		"latex",
		"git_config",
		"hyprlang",
		"rasi",
		"c",
		"typst",
		"wim",
	},
	highlight = { enable = true },
	autopairs = {
		enable = true,
	},
})

vim.filetype.add({
	extension = { kbd = "kbd", rasi = "rasi", rofi = "rasi", wofi = "rasi" },
	filename = {
		["vifmrc"] = "vim",
	},
	pattern = {
		[".*/waybar/config"] = "jsonc",
		[".*/kitty/.+%.conf"] = "kitty",
		[".*/hypr/.+%.conf"] = "hyprlang",
		["%.env%.[%w_.-]+"] = "sh",
	},
})

vim.treesitter.language.register("kanata", "kbd")

vim.treesitter.language.register("bash", "kitty")
