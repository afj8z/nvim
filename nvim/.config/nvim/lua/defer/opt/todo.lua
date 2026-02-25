local function load_todo()
	require("todo-comments").setup({
		gui_style = {
			fg = "NONE", -- The gui style to use for the fg highlight group.
			bg = "BOLD", -- The gui style to use for the bg highlight group.
		},
		highlight = {
			after = "",
		},
	})
end

return {
	name = "todo",
	src = "https://github.com/folke/todo-comments.nvim.git",
	load = load_todo,
	cmds = {
		"TodoLocList",
		"TodoQuickFix",
		{ cmd = "TodoTelescope", deps = { "telescope" } },
	},
	libs = { "plenary" },
}
