local ls = require("luasnip")
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local function _snip(trigger, nodes, opts)
	opts = opts or {}

	local trigger_opts = {
		trig = trigger,
		name = opts.name,
		wordTrig = opts.wordTrig == nil and true or opts.wordTrig,
		priority = opts.priority,
	}

	if opts.regTrig then
		trigger_opts.regTrig = true
	end

	if opts.name then
		trigger_opts.name = opts.name
	end

	opts.name = ""
	opts.wordTrig = nil
	opts.regTrig = nil
	opts.priority = nil

	return s(trigger_opts, nodes, opts)
end

-- Helper to make punctuation-led autosnips concise
local function AS(trig, nodes, args)
	return s(
		{ trig = trig, wordTrig = false, snippetType = "autosnippet" },
		nodes,
		args
	)
end

local function heading_level(args, parent)
	local lvl = parent.captures[2]
	local num = tonumber(lvl)

	if type(num) ~= "number" then
		return error("Snippet parseing failed to capture number")
	end

	local final_text = string.rep("#", num)

	return sn(nil, { t(final_text) })
end

return {
	AS("^TASK", { t("- [ ]") }, { regTrig = true }),
}, {

	_snip(
		"^[^%a+%d+]?(h)(%d)",
		fmt("{} {}", { d(1, heading_level), i(0) }),
		{ regTrig = true, wordTrig = false }
	),
}
