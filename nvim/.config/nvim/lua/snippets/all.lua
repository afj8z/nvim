local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key

local npairs = {
	{ "(", ")" },
	{ "{", "}" },
	{ "[", "]" },
	{ "[", "]" },
	{ '"', '"' },
}

local mapped_snippets = {}
for _, trigger in pairs(npairs) do
	local t1 = trigger[1]
	local t2 = trigger[2]

	local snipp = s({ trig = t1, wordTrig = false, snippetType = "autosnippet" }, {
		t(t1),
		i(0),
		t(t2),
	}, {
		condition = function()
			local line = vim.api.nvim_get_current_line()
			local _, col = unpack(vim.api.nvim_win_get_cursor(0))
			local eol = string.sub(line, col + 1)

			-- identical pairs
			if t1 == t2 then
				local _, count = string.gsub(line, "%" .. t1, "")
				return count % 2 ~= 0
			end

			-- distinct pairs
			if not string.match(eol, "%" .. t2) then
				return true
			end

			local _, open_count = string.gsub(line, "%" .. t1, "")
			local _, close_count = string.gsub(line, "%" .. t2, "")

			return open_count > close_count
		end,
	})

	table.insert(mapped_snippets, snipp)
end

return {
	-- Regular snippets
	s("ctrig", t("also loaded!!")),
}, {
	-- Autosnippets
	s("autotrig", t("autotriggered, if enabled")),
	-- s("121", {
	-- 	i(1, "INPUT"),
	-- 	t({ "", "" }),
	-- 	m(1, l._1:match(l._1:reverse()), "PALINDROME"),
	-- }),
	-- unpack(mapped_snippets),
}
