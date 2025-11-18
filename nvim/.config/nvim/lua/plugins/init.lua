require("nIM").setup({
	run_file = {
		keymap = "<leader>a",
	},
})

require("utils").load_modules("plugins", {
	"oil",
	"ts",
	"typpv",
	"blcmp",
	"format",
	"runfile",
	"fzf",
	"colorize",
	-- "bracketm",
	"copilot",
})
