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

local in_math = require("snippets.typst-mode").is_in_math
local not_math = require("snippets.typst-mode").not_in_math

-- Helper function to create an auto-expanding math snippet
local function math_snippet(trigger, nodes, opts)
	opts = opts or {}

	local trigger_opts = {
		trig = trigger,
		wordTrig = opts.wordTrig == nil and true or opts.wordTrig,
	}

	if opts.regTrig then
		trigger_opts.regTrig = true
	end

	opts.condition = in_math
	opts.wordTrig = nil
	opts.regTrig = nil

	return s(trigger_opts, nodes, opts)
end

local function not_math_s(trigger, nodes, opts)
	opts = opts or {}

	local trigger_opts = {
		trig = trigger,
		wordTrig = opts.wordTrig == nil and true or opts.wordTrig,
	}

	if opts.regTrig then
		trigger_opts.regTrig = true
	end

	opts.condition = not_math
	opts.wordTrig = nil
	opts.regTrig = nil

	return s(trigger_opts, nodes, opts)
end

local greek_map = {
	[",a"] = "alpha",
	[",b"] = "beta",
	[",g"] = "gamma",
	[",d"] = "delta",
	[",e"] = "epsilon",
	[",z"] = "zeta",
	[",et"] = "eta",
	[",th"] = "theta",
	[",i"] = "iota",
	[",k"] = "kappa",
	[",l"] = "lambda",
	[",m"] = "mu",
	[",n"] = "nu",
	[",x"] = "xi",
	[",o"] = "omicron",
	[",p"] = "pi",
	[",r"] = "rho",
	[",s"] = "sigma",
	[",t"] = "tau",
	[",u"] = "upsilon",
	[",ph"] = "phi",
	[",ch"] = "chi",
	[",ps"] = "psi",
	[",w"] = "omega",
	-- Uppercase
	[",G"] = "Gamma",
	[",D"] = "Delta",
	[",Th"] = "Theta",
	[",L"] = "Lambda",
	[",X"] = "Xi",
	[",P"] = "Pi",
	[",S"] = "Sigma",
	[",U"] = "Upsilon",
	[",Ph"] = "Phi",
	[",Ps"] = "Psi",
	[",W"] = "Omega",
}

local greek_snippets = {}

for trigger, expansion in pairs(greek_map) do
	table.insert(greek_snippets, math_snippet(trigger, { t(expansion) }))
end

local function format_subscript(args, parent)
	local letter = parent.captures[1]
	local digits = parent.captures[2]

	local final_text
	if #digits > 1 then
		final_text = letter .. "_(" .. digits .. ")"
	else
		final_text = letter .. "_" .. digits
	end

	return sn(nil, { t(final_text) })
end

return {}, {
	-- AUTO-EXPANDING MATH SNIPPETS

	math_snippet("uu", fmt("^({})", { i(1) }), { wordTrig = false }),

	math_snippet("dd", fmt("_({})", { i(1) }), { wordTrig = false }),

	math_snippet("int", fmt("integral_({})^({})", { i(1), i(2) })),

	math_snippet("diff", fmt("diff/diff({})", { i(1) })),

	math_snippet("pde", fmt("partial/partial{}", { i(1) })),

	math_snippet("inf", { t("oo") }),

	math_snippet("=>", { t("==>") }),

	math_snippet("->", { t("->") }),

	math_snippet("!=", { t("!=") }),

	math_snippet("usr", { t("^(2)") }),

	math_snippet("ucb", { t("^(3)") }),

	math_snippet("bar", fmt("bar({})", { i(1) })),

	math_snippet("hat", fmt("hat({})", { i(1) })),

	math_snippet("vec", fmt("vec({})", { i(1) })),

	math_snippet("sqrt", fmt("sqrt({})", { i(1) })),

	math_snippet("sum", fmt("sum_({})^({})", { i(1), i(2) })),

	math_snippet("lim", fmt("lim_({})", { i(1, "n -> oo") })),

	math_snippet("prod", fmt("prod_({})^({})", { i(1, "i=1"), i(2, "n") })),

	math_snippet("ob", fmt("overbrace({}, {})", { i(1), i(2) })),

	math_snippet("ub", fmt("underbrace({}, {})", { i(1), i(2) })),

	math_snippet("ol", fmt("overline({})", { i(1) })),

	math_snippet("abs", fmt("abs({})", { i(1) })),

	math_snippet("bin", fmt("binom({}, {})", { i(1, "n"), i(2, "k") })),

	math_snippet("([a-zA-Z])(%d+) ", { d(1, format_subscript) }, { regTrig = true, wordTrig = false }),

	not_math_s("mm", fmt("${}$ ", { i(1) })),

	unpack(greek_snippets),
}
