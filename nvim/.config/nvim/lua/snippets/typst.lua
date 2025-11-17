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
local line_begin = require("luasnip.extras.expand_conditions").line_begin
local mode = require("snippets.util.logic")
local cstm_gen = require("snippets.util.format")
local format_subscript = cstm_gen.format_subscript
local heading_level = cstm_gen.heading_level
local generate_row = cstm_gen.generate_row
local generate_fraction = cstm_gen.generate_fraction
local expand_equation = cstm_gen.expand_equation
local which_mode = cstm_gen.which_math_mode
local generate_matrix = cstm_gen.generate_matrix
local generate_cases = cstm_gen.generate_cases
local format_probability = cstm_gen.format_probability
local format_symbol = cstm_gen.format_symbol
local return_capture = cstm_gen.return_capture
local frac_logic = cstm_gen.frac_logic
local testarg = cstm_gen.test_arg
local single_probability = cstm_gen.single_probability
local sub_symbol = cstm_gen.sub_symbol
local build_screenshot_node = cstm_gen.build_screenshot_node
local generate_template = cstm_gen.generate_template
local dynamic_file_name = cstm_gen.get_dynamic_project_name

local math_snippet = mode.math_snippet
local not_math_s = mode.not_math_s

local mapped_snippets = require("snippets.util.maps").return_map()

return {

	not_math_s(
		"sepage",
		fmta(
			[[
		#import "@local/conf:0.1.0": *
		#import "@local/boxes:0.1.0": *

		#show: init_pageless.with(
			norm: 11pt,
			preset: "Aidan",
			title: "<>",
			subtitle: "<>",
			lang: (setting: "de"),
			color_theme: "light",
			accent: (switch: true),
			q_count: 0,
		)
		<>
		]],
			{
				f(dynamic_file_name),
				d(1, generate_template),
				i(0),
			}
		)
	),
}, {
	math_snippet(
		"arr([%a])",
		fmt("arrow.{} ", {
			f(function(_, snip)
				return snip.captures[1]
			end),
		}),
		{ regTrig = true, wordTrig = false }
	),

	-- ^asterisk (max etc)
	math_snippet(
		"([%a%)%]%}])%*%*",
		fmt("{}^(*) {}", { f(function(_, snip)
			return snip.captures[1]
		end), i(0) }),
		{ regTrig = true, wordTrig = false }
	),
	-- log with subscript
	math_snippet(
		"ll(.*)%s",
		fmt("log_({}) {}", { f(function(_, snip)
			return snip.captures[1]
		end), i(0) }),
		{ regTrig = true }
	),
	math_snippet(
		"([%a%d])([%a%d])mm",
		fmt("({} times {}) {}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			f(function(_, snip)
				return snip.captures[2]
			end),
			i(0),
		}),
		{ regTrig = true }
	),
	-- transposed matrix
	math_snippet(
		"([a-zA-Z%)%]%}])TT",
		fmt("{}^(T) {}", { f(function(_, snip)
			return snip.captures[1]
		end), i(0) }),
		{ regTrig = true, wordTrig = false }
	),

	math_snippet("kk", fmt("^({}) ", { i(1) }), { wordTrig = false }),
	math_snippet("jj", fmt("_({}) ", { i(1) }), { wordTrig = false }),
	math_snippet("JK", fmt("_({})^({}) ", { i(1), i(2) }), { wordTrig = false }),

	math_snippet("int", fmt("integral_({})^({})", { i(1), i(2) })),
	math_snippet("dvv", fmt("mat({}) dot vec({})", { i(1), i(2) })),

	math_snippet(
		"vv(%a+) ",
		fmt("vec({}) {}", {
			d(1, return_capture, {}, { user_args = { "comma" } }),
			i(2),
		}),
		{ regTrig = true }
	),

	math_snippet(
		"fu([%a%d]*) ",
		fmt("f_({})({}) ", {
			d(1, return_capture, {}, { user_args = { "comma_num_down" } }),
			i(2),
		}),
		{ regTrig = true }
	),
	math_snippet(
		"avv(%a+) ",
		fmt("vec({}) {}", {
			d(1, return_capture, {}, { user_args = { "space" } }),
			i(2),
		}),
		{ regTrig = true }
	),

	math_snippet("diff", fmt("diff/diff({}) ", { i(1) })),

	math_snippet("pde", fmt("partial/partial{} ", { i(1) })),

	math_snippet("usr", { t("^(2)") }, { wordTrig = true }),

	math_snippet("ucb", { t("^(3)") }, { wordTrig = true }),

	math_snippet("bar", fmt("bar({})", { i(1) })),

	math_snippet("hat", fmt("hat({})", { i(1) })),

	math_snippet("vec", fmt("vec({})", { i(1) })),

	math_snippet("sqr", fmt("sqrt({}) ", { i(1) })),

	math_snippet("sum", fmt("sum_({})^({}) ", { i(1), i(2) })),

	math_snippet("lim", fmt("lim_({}) ", { i(1, "n -> oo") })),

	math_snippet("prod", fmt("product_({})^({}) ", { i(1, "i=1"), i(2, "n") })),

	math_snippet("ob", fmt("overbrace({}, {}) ", { i(1), i(2) })),

	math_snippet("ub", fmt("underbrace({}, {}) ", { i(1), i(2) })),

	math_snippet("ol", fmt("overline({}) ", { i(1) })),

	math_snippet("abs", fmt("abs({}) ", { i(1) })),

	math_snippet("bin", fmt("binom({}, {}) ", { i(1, "n"), i(2, "k") })),

	math_snippet("rng", fmt("underbrace({}, {}) ", { i(1), i(2) })),

	math_snippet("([a-zA-Z])(%d+) ", { d(1, format_subscript) }, { regTrig = true, wordTrig = false }),

	math_snippet("([A-Z])([a-z]) ", { d(1, format_subscript) }, { regTrig = true, wordTrig = false }),

	math_snippet("(%d+)ff", { d(1, generate_fraction) }, { regTrig = true, wordTrig = false }),

	math_snippet(
		"(.*[%)]?[^%w%a])ff",
		fmt("{}, {}) ", {
			d(1, frac_logic),
			i(2),
		}),

		{ regTrig = true, wordTrig = false }
	),

	math_snippet(
		"P([o]?[A-Z]) ",
		fmt("P({}) {}", {
			d(1, single_probability),
			i(0),
		}),
		{ regTrig = true, wordTrig = false }
	),

	math_snippet(
		"P([o]?[A-Z])([usic])([o]?[A-Z])([usic]?)([o]?[A-Z]?) ",
		fmt("P({}{}{}{}{}){}", {
			d(1, single_probability),
			d(2, sub_symbol, {}, {
				user_args = {
					2,
					{
						["u"] = "union",
						["s"] = "inter",
						["i"] = "bot",
						["c"] = "|",
					},
				},
			}),
			d(3, single_probability, {}, { user_args = { 3 } }),
			d(4, sub_symbol, {}, {
				user_args = {
					4,
					{
						["u"] = "union",
						["s"] = "inter",
						["i"] = "bot",
						["c"] = "|",
					},
				},
			}),
			d(5, single_probability, {}, { user_args = { 5 } }),
			i(0),
		}),
		{ regTrig = true, wordTrig = false }
	),

	math_snippet(
		"([bBpvV]?)mat(%d)(%d)",
		fmta(
			[[
	mat(delim:<>,
	<>
	)<>]],
			{
				f(function(_, snip)
					local prefix = snip.captures[1] or ""
					if (prefix == "b") or (prefix == "B") then
						return '"["'
					elseif (prefix == "p") or prefix == "v" or prefix == "V" then
						return '"{"'
					else
						return '"("'
					end
				end),
				d(1, generate_matrix),
				i(0),
			}
		),
		{ regTrig = true }
	),

	math_snippet(
		"css(%d)",
		fmta(
			[[
	cases(
	<>
	)<>]],
			{ d(1, generate_cases), i(0) }
		),
		{ regTrig = true }
	),

	not_math_s("mm(.)", fmt("{} {}", { d(1, which_mode), i(0) }), { regTrig = true, wordTrig = true }),

	not_math_s("^(h)(%d)", fmt("{} {}", { d(1, heading_level), i(0) }), { regTrig = true, wordTrig = false }),

	not_math_s("^(MM)", fmt("$\n	{}\n$\n{} ", { i(1), i(2) }), { regTrig = true }),

	not_math_s("^(MM)", fmt("$\n	{}\n$\n{} ", { i(1), i(2) }), { regTrig = true }),

	-- idk if their is an easier way to pass capture group indexes to
	-- functions
	math_snippet(
		"([%d]?)TEST(%d)",
		fmt("first:{}second:{}", {
			d(1, testarg, {}, { user_args = { 1 } }),
			d(2, testarg, {}, { user_args = { 2 } }),
		}),
		{ regTrig = true, wordTrig = false }
	),

	-- passing a table in userrags. What sort of dynamic hell could we create
	-- with this
	math_snippet(
		"SUBSYM([usic])",
		fmt("symbol:{}", {
			d(1, sub_symbol, {}, {
				user_args = {
					1,
					{
						["u"] = "union",
						["s"] = "inter",
						["i"] = "bot",
						["c"] = "|",
					},
				},
			}),
		}),
		{ regTrig = true, wordTrig = false }
	),

	not_math_s(
		"SNIP",
		-- This template has two placeholders:
		-- 1. The main block, generated by the d-node
		-- 2. The final cursor position (i(0))
		fmt("{}\n{}", {
			-- Placeholder 1: Call the dynamic function
			d(1, build_screenshot_node),
			i(0),
		})
	),
	unpack(mapped_snippets),
}
