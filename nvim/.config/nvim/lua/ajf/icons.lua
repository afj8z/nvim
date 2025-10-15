local M = {}

local sym = require("utils").get_settings().symbols

--- Diagnostic severities.
M.diagnostics = {
	ERROR = sym.error,
	WARN = sym.warn,
	HINT = sym.hint,
	INFO = sym.info,
}

--- For folding.
M.arrows = {
	right = "",
	left = "",
	up = "",
	down = "",
}

--- LSP symbol kinds.
M.symbol_kinds = {
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
}

--- Shared icons that don't really fit into a category.
M.misc = {
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
}

return M
