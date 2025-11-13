local ls = require("luasnip")
local t = ls.text_node
local math_snippet = require("snippets.util.logic").math_snippet
local M = {}

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

local operator_map = {
	["imp"] = "==>",
	["to"] = "->",
	["lrar"] = "<=>",
	["larr"] = "-->",
	["larl"] = "<--",
	["map"] = "mapsto",
	["~~"] = "approx",
	["subs"] = "subset",
	["sups"] = "supset",
	["uni"] = "union",
	["sec"] = "inter",
	["diam"] = "diameter",
	["..."] = "dots.c",
	["xx"] = "dot",
	["tt"] = "times",
	["inf"] = "oo",
	["fall"] = "forall",
	["pp"] = "+",
	["ee"] = "=",
	["gte"] = "gt.eq",
	["lte"] = "lt.eq",
}

local mapped_snippets = {}

for trigger, expansion in pairs(operator_map) do
	table.insert(mapped_snippets, math_snippet(trigger, { t(expansion) }, { wordTrig = false }))
end

for trigger, expansion in pairs(greek_map) do
	table.insert(mapped_snippets, math_snippet(trigger, { t(expansion) }, { wordTrig = true }))
end

function M.return_map()
	return mapped_snippets
end

return M
