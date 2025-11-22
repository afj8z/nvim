local ls = require("luasnip")
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

---Returns the indentation of the line the snippet was triggered on
local function get_indent(_, snip)
	local line = vim.api.nvim_buf_get_lines(0, snip.trigger_line, snip.trigger_line + 1, false)[1]
	local indent_str = line:match("^(%s*)")
	return indent_str or ""
end

ls.setup_snip_env()

return {
	["{"] = ls.parser.parse_snippet("keymap_{", fmt([[\n\t{}\n{}]], { i(1), f(get_indent) })),

	["["] = ls.parser.parse_snippet("keymap_[", fmt([[\n\t{}\n{}[]], { i(1), f(get_indent) })),

	["("] = ls.parser.parse_snippet("keymap_(", fmt([[\n\t{}\n{})]], { i(1), f(get_indent) })),
}
