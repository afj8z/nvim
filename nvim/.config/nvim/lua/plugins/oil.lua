vim.pack.add({
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/JezerM/oil-lsp-diagnostics.nvim" },
})

local sym = require("ajf.icons").diagnostics
local style = require("utils").get_settings()

require("oil").setup({
	default_file_explorer = true,
	columns = {
		"icon",
		"permissions",
		-- "size",
		-- "mtime",
	},
	skip_confirm_for_simple_edits = false,
	prompt_save_on_select_new_entry = true,
	view_options = {
		show_hidden = true,
		sort = {
			{ "type", "asc" },
			{ "name", "asc" },
		},
	},
	float = {
		border = style.border,
		preview_split = "right",
	},
	preview_win = {
		update_on_cursor_moved = true,
		preview_method = "fast_scratch",
	},
	confirmation = {
		border = style.border,
	},
	progress = {
		border = style.border,
	},
	ssh = {
		border = style.border,
	},
	keymaps_help = {
		border = style.border,
	},
})

require("oil-lsp-diagnostics").setup({
	diagnostic_symbols = {
		error = sym.ERROR,
		warn = sym.WARN,
		info = sym.INFO,
		hint = sym.HINT,
	},
})
