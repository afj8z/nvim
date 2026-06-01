local function load_treesitter()
	local ft_to_parse = {
		"make",
		"toml",
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
		"latex",
		"git_config",
		"hyprlang",
		"rasi",
		"c",
		"cpp",
		"typst",
		"sql",
		"kbd",
		"r",
		"julia",
	}
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft_to_parse,
		callback = function()
			vim.treesitter.start()
		end,
	})

	vim.filetype.add({
		extension = {
			kbd = "kbd",
			rasi = "rasi",
			rofi = "rasi",
			wofi = "rasi",
		},
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

	vim.api.nvim_create_autocmd("User", {
		pattern = "TSUpdate",
		callback = function()
			require("nvim-treesitter.parsers").kanata = {
				install_info = {
					path = "/home/aidanfleming/src/tree-sitter-kanata", -- Local directory
					files = { "src/parser.c" },
					generate = false,
				},
			}
			require("nvim-treesitter.parsers").wonkey = {
				install_info = {
					path = "/home/aidanfleming/dev/wonkey_parser/", -- Local directory
					files = { "src/parser.c" },
					generate = false,
				},
			}
		end,
	})

	vim.filetype.add({
		extension = {
			kbd = "kanata",
			h = "c",
		},
	})

	vim.treesitter.language.register("kanata", "kbd")
	vim.treesitter.language.register("wonkey", "wonkey")
end

return {
	name = "treesitter",
	src = "https://github.com/nvim-treesitter/nvim-treesitter",
	load = load_treesitter,
}
