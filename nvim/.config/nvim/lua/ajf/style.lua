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
		Color = "󰏘",
		Folder = "󰉋",
		Keyword = { icon = "󰌋", hl = "Function" },
		Reference = "󰈇",
		Snippet = "",
		Text = "",
		Unit = "",
		Value = "󰎠",
		File = { icon = "󰈙", hl = "Identifier" },
		Module = { icon = "󰆧", hl = "Include" },
		Namespace = { icon = "󰅪", hl = "Include" },
		Package = { icon = "󰏗", hl = "Include" },
		Class = { icon = "", hl = "Type" },
		Method = { icon = "ƒ", hl = "Function" },
		Property = { icon = "󰜢", hl = "Identifier" },
		Field = { icon = "", hl = "@field" },
		Constructor = { icon = "", hl = "@constructor" },
		Enum = { icon = "", hl = "Number" },
		Interface = { icon = "", hl = "Type" },
		Function = { icon = "󰊕", hl = "Function" },
		Variable = { icon = "󰀫", hl = "Variable" },
		Constant = { icon = "󰏿", hl = "Constant" },
		String = { icon = "", hl = "String" },
		Number = { icon = "#", hl = "Number" },
		Boolean = { icon = "⊨", hl = "Boolean" },
		Array = { icon = "󰅪", hl = "@constructor" },
		Object = { icon = "⦿", hl = "Type" },
		Key = { icon = "🔐", hl = "Type" },
		Null = { icon = "NULL", hl = "Type" },
		EnumMember = { icon = "", hl = "Number" },
		Struct = { icon = "󰙅", hl = "Structure" },
		Event = { icon = "", hl = "Type" },
		FCall = { icon = "󰅲", hl = "Function" },
		Operator = { icon = "󰆕", hl = "Operator" },
		TypeParameter = { icon = "𝙏", hl = "Identifier" },
		Component = { icon = "󰅴", hl = "Function" },
		Fragment = { icon = "󰅴", hl = "Constant" },
		TypeAlias = { icon = "", hl = "Type" },
		Parameter = { icon = "", hl = "Parameter" },
		StaticMethod = { icon = "", hl = "Function" },
		Macro = { icon = "", hl = "Function" },
		Heading = { icon = "󰉴", hl = "Keyword" },
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
