local function load_todo()
	local Snacks = require("snacks")
	require("todo-comments").setup({
		optional = true,
		gui_style = {
			fg = "NONE", -- The gui style to use for the fg highlight group.
			bg = "BOLD", -- The gui style to use for the bg highlight group.
		},
		highlight = {
			after = "",
		},
	})
	vim.keymap.set("n", "<leader>st", function()
		Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
	end, { desc = "Todo" })
end

return {
	name = "todo",
	src = "https://github.com/folke/todo-comments.nvim.git",
	load = load_todo,
	cmds = { "TodoLocList", "TodoQuickFix" },
	libs = { "plenary" },
}
