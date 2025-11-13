local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Helper to make punctuation-led autosnips concise
local function AS(trig, nodes, args)
	return s({ trig = trig, wordTrig = false, snippetType = "autosnippet" }, nodes, args)
end

return {
	AS("^TASK", { t("- [ ]") }, { regTrig = true }),
}
