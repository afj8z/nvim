local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

local in_math = require("snippets.typst-mode").is_in_math
local not_math = require("snippets.typst-mode").not_in_math

-- Helper function to create an auto-expanding math snippet
local function math_snippet(trigger, nodes, opts)
	opts = opts or {}

	local trigger_opts = {
		trig = trigger,
		wordTrig = opts.wordTrig == nil and true or opts.wordTrig,
		priority = opts.priority,
	}

	if opts.regTrig then
		trigger_opts.regTrig = true
	end

	opts.condition = in_math
	opts.wordTrig = nil
	opts.regTrig = nil
	opts.priority = nil

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

local generate_fraction = function(args, parent)
	local stripped = parent.captures[1]
	return sn(nil, { t("frac(" .. stripped .. ", "), i(1), t(")") })
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
	[",G"] = "Gamma",
	[",D"] = "Delta",
	[",T"] = "Theta",
	[",L"] = "Lambda",
	[",X"] = "Xi",
	[",P"] = "Pi",
	[",S"] = "Sigma",
	[",U"] = "Upsilon",
	[",Ph"] = "Phi",
	[",Ps"] = "Psi",
	[",O"] = "Omega",
}

local greek_snippets = {}

for trigger, expansion in pairs(greek_map) do
	table.insert(greek_snippets, math_snippet(trigger, { t(expansion) }))
end

local operator_map = {
	["imp"] = "==>",
	["to"] = "->",
	["lrar"] = "<=>",
	["larr"] = "-->",
	["larl"] = "<--",
	["map"] = "mapsto",
	["subs"] = "subset",
	["sups"] = "supset",
	["uni"] = "union",
	["sec"] = "inter",
	["diam"] = "diameter",
	["..."] = "dots.c",
	["xx"] = "dot",
	["inf"] = "oo",
	["fall"] = "forall",
	["pp"] = "+",
	["mm"] = "-",
	["ee"] = "=",
	["gte"] = "gt.eq",
	["lte"] = "lt.eq",
}

local operator_snippets = {}

for trigger, expansion in pairs(operator_map) do
	table.insert(operator_snippets, math_snippet(trigger, { t(expansion) }))
end

return {}, {

	math_snippet("uu", fmt("^({})", { i(1) }), { wordTrig = false }),

	math_snippet("dd", fmt("_({})", { i(1) }), { wordTrig = false }),

	math_snippet("int", fmt("integral_({})^({})", { i(1), i(2) })),

	math_snippet("diff", fmt("diff/diff({})", { i(1) })),

	math_snippet("pde", fmt("partial/partial{}", { i(1) })),

	math_snippet("usr", { t("^(2)") }),

	math_snippet("ucb", { t("^(3)") }),

	math_snippet("bar", fmt("bar({})", { i(1) })),

	math_snippet("hat", fmt("hat({})", { i(1) })),

	math_snippet("vec", fmt("vec({})", { i(1) })),

	math_snippet("sqrt", fmt("sqrt({})", { i(1) })),

	math_snippet("sum", fmt("sum_({})^({})", { i(1), i(2) })),

	math_snippet("lim", fmt("lim_({})", { i(1, "n -> oo") })),

	math_snippet("prod", fmt("product_({})^({})", { i(1, "i=1"), i(2, "n") })),

	math_snippet("ob", fmt("overbrace({}, {})", { i(1), i(2) })),

	math_snippet("ub", fmt("underbrace({}, {})", { i(1), i(2) })),

	math_snippet("ol", fmt("overline({})", { i(1) })),

	math_snippet("abs", fmt("abs({})", { i(1) })),

	math_snippet("bin", fmt("binom({}, {})", { i(1, "n"), i(2, "k") })),

	math_snippet("rng", fmt("underbrace({}, {})", { i(1), i(2) })),

	math_snippet("([a-zA-Z])(%d+) ", { d(1, format_subscript) }, { regTrig = true, wordTrig = false }),

	math_snippet("(%d+)//", { d(1, generate_fraction) }, { regTrig = true, wordTrig = false }),

	not_math_s("mm", fmt("${}$ ", { i(1) })),

	not_math_s("(^MM)", fmt("$ {} $ ", { i(1) }), { regTrig = true }),

	unpack(greek_snippets),

	unpack(operator_snippets),
}
