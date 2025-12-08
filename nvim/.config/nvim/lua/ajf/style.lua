local M = {}

local sym = require("ajf.utils").get_settings().symbols

--- Diagnostic severities.
M.icons = {
	diagnostics = {
		ERROR = sym.error,
		WARN = sym.warn,
		HINT = sym.hint,
		INFO = sym.info,
	},

	--- For folding.
	arrows = {
		right = "",
		left = "",
		up = "",
		down = "",
	},

	--- LSP symbol kinds.
	symbol_kinds = {
		Array = "󰅪",
		Class = "",
		Color = "󰏘",
		Constant = "󰏿",
		Constructor = "",
		Enum = "",
		EnumMember = "",
		Event = "",
		Field = "󰜢",
		File = "󰈙",
		Folder = "󰉋",
		Function = "󰆧",
		Interface = "",
		Keyword = "󰌋",
		Method = "󰆧",
		Module = "",
		Operator = "󰆕",
		Property = "󰜢",
		Reference = "󰈇",
		Snippet = "",
		Struct = "",
		Text = "",
		TypeParameter = "",
		Unit = "",
		Value = "",
		Variable = "󰀫",
	},

	--- Shared icons that don't really fit into a category.
	misc = {
		bug = "",
		dashed_bar = "┊",
		ellipsis = "…",
		git = "",
		palette = "󰏘",
		robot = "󰚩",
		search = "",
		terminal = "",
		toolbox = "󰦬",
		vertical_bar = "│",
	},
}

return M
