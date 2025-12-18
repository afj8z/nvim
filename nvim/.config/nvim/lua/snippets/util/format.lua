local ls = require("luasnip")
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt
local f = ls.function_node

local M = {}
function M.generate_fraction(args, parent)
	local stripped = parent.captures[1]
	return sn(nil, { t("frac(" .. stripped .. ", "), i(1), t(")") })
end

function M.generate_row(args, parent)
	local var = parent.captures[1]
	local sub = parent.captures[2]
	local sign = parent.captures[3]

	local final_text = var
		.. "_("
		.. sub
		.. ") "
		.. sign
		.. " "
		.. var
		.. "_("
		.. sub + 1
		.. ") "
		.. sign
		.. " "
		.. var
		.. "_("
		.. sub + 2
		.. ") "
		.. sign
		.. " dots "
		.. sign
		.. " "
		.. var
		.. " _(n-1) "
		.. sign
		.. " "
		.. var
		.. "_n "

	return sn(nil, { t(final_text) })
end

function M.format_subscript(args, parent)
	local letter = parent.captures[1]
	local digits = parent.captures[2]

	local final_text
	if #digits > 1 then
		final_text = letter .. "_(" .. digits .. ")"
	else
		final_text = letter .. "_" .. digits
	end

	return sn(nil, { t(final_text .. " ") })
end

function M.heading_level(args, parent)
	local lvl = parent.captures[2]
	local num = tonumber(lvl)

	local final_text = string.rep("=", num)

	return sn(nil, { t(final_text) })
end

function M.expand_equation(args, parent)
	local lower = parent.captures[1]
	local upper = parent.captures[2]
	local opp = parent.captures[3]

	local final_text = opp .. "_(" .. lower .. ")^(" .. upper .. ") "

	return sn(nil, { t(final_text) })
end

function M.which_math_mode(args, parent)
	local input = parent.captures[1]
	if input == " " then
		return sn(nil, {
			t("$"),
			t({ "", "		" }),
			i(1),
			t({ "", "$", "" }),
			i(2),
		})
	else
		-- Uses d(2) watching i(0)
		return sn(nil, {
			t("$"),
			t(input),
			i(1),
			t("$"),
			i(0),
		})
	end
end

-- Generating functions for Matrix/Cases - thanks L3MON4D3!
function M.generate_matrix(args, snip)
	local rows = tonumber(snip.captures[2])
	local cols = tonumber(snip.captures[3])
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
		ins_indx = ins_indx + 1
		for k = 2, cols do
			table.insert(nodes, t(" , "))
			table.insert(
				nodes,
				r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1))
			)
			ins_indx = ins_indx + 1
		end
		table.insert(nodes, t({ ";", "" }))
	end
	-- fix last node.
	nodes[#nodes] = t(";")
	return sn(nil, nodes)
end

function M.generate_cases(args, snip)
	local rows = tonumber(snip.captures[1]) or 2 -- default option 2 for cases
	local cols = 2                            -- fix to 2 cols
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
		ins_indx = ins_indx + 1
		for k = 2, cols do
			table.insert(nodes, t(" & "))
			table.insert(
				nodes,
				r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1))
			)
			ins_indx = ins_indx + 1
		end
		table.insert(nodes, t({ ",", "" }))
	end
	-- fix last node.
	table.remove(nodes, #nodes)
	return sn(nil, nodes)
end

function M.format_probability(args, parent)
	local isbar = args[1]
	local var = args[2]

	local final_text

	if isbar == "o" then
		final_text = "overline(" .. var .. ")"
	else
		final_text = var
	end

	return sn(nil, { t(final_text) })
end

function M.format_symbol(args)
	local sym = args[1] -- This will be capture group 3 ("u", "s", etc.)
	if sym == "u" then
		return " union "
	elseif sym == "s" then
		return " inter "
	elseif sym == "i" then
		return " bot "
	elseif sym == "c" then
		return " | "
	end
	return ""
end

M.return_capture = function(args, parent, _, split_type)
	local str = parent.captures[1]

	if split_type == "space" then
		local split_text = {}

		for char in str:gmatch(".") do
			table.insert(split_text, char)
		end

		local final_text = table.concat(split_text, " ")
		return sn(nil, { t(final_text) })
	elseif split_type == "comma" then
		local split_text = {}

		for char in str:gmatch(".") do
			table.insert(split_text, char)
		end

		local final_text = table.concat(split_text, ", ")
		return sn(nil, { t(final_text) })
	elseif split_type == "comma_num_down" then
		local split_text = {}

		for char in str:gmatch("%a%d") do
			char = char:gsub("()", { [2] = "_" })
			table.insert(split_text, char)
		end

		str = str:gsub("%a%d", "")

		for char in str:gmatch("([^%d]*)") do
			for let in char:gmatch(".") do
				table.insert(split_text, let)
			end
		end

		local final_text = table.concat(split_text, ", ")
		return sn(nil, { t(final_text) })
	else
		return sn(nil, { t(str) })
	end
end

function M.frac_logic(args, parent)
	local text = parent.captures[1]
	-- Case 1
	if text == "" then
		return sn(nil, { t("frac("), i(1) })
	end

	-- Case 2 - failcase in rare situations that 1 doesnt trigger (dont know why
	-- or how it works - it just does.)
	if text:sub(-1) ~= ")" then
		return sn(nil, { t(text .. "frac("), i(1) })
	end

	-- Case 3
	if text:sub(-1) == ")" then
		local balance = 1
		local start_index = -1
		for i = #text - 1, 1, -1 do
			local char = text:sub(i, i)
			if char == ")" then
				balance = balance + 1
			elseif char == "(" then
				balance = balance - 1
			end

			if balance == 0 then
				start_index = i
				break
			end
		end
		if start_index == -1 then
			return sn(nil, { t("frac(" .. text), i(1) })
		else
			local line_before = text:sub(1, start_index - 1)

			local paren_content = text:sub(start_index + 1, #text - 1)

			return sn(nil, { t(line_before .. "frac(" .. paren_content) })
		end
	end
end

function M.test_arg(args, parent, _, index)
	local first = parent.captures[index]
	return sn(nil, t(first))
end

function M.single_probability(args, parent, _, index)
	if index == nil or index == "" then
		index = 1
	end
	local pad = ""
	if index >= 4 then
		pad = " "
	end
	local var = parent.captures[index] or ""
	if var == "0" then
		var = "emptyset"
	end
	if var == "O" then
		var = "Omega"
	end
	if #var == 2 then
		var = "overline(" .. var:sub(2, 2) .. ")"
	elseif #var == 2 then
		var = var
	end
	return sn(nil, t(pad .. var))
end

function M.sub_symbol(args, parent, _, index, map)
	local text = parent.captures[index] or ""
	local sub
	if text ~= "" then
		sub = " " .. map[text] .. " "
	else
		sub = ""
	end
	return sn(nil, t(sub))
end

function M.build_screenshot_node(args, parent_snippet)
	local ftype = vim.bo.filetype
	if ftype ~= "typst" then
		return sn(nil, { t("ERROR: Not a typst file") })
	end

	local filePath = vim.fs.normalize("~/.typst/local/snips/0.1.0/snipmap.csv")
	local lastLine = vim.fn.system({ "awk", "END{print}", filePath })

	if not lastLine or lastLine == "" then
		return sn(nil, { t("ERROR: snipmap.csv is empty") })
	end
	local snip = lastLine:gsub(",.*$", "")

	local unique_name = "fig_" .. os.date("%Y%m%d%H%M%S")

	local nodes = {
		t("#let " .. unique_name .. ' = snap(snip("' .. snip .. '"), "'),
		i(1, '"Caption"'), -- First stop
		t('", size: '),
		i(3, "8em"), -- Third stop
		t({ ")", "#wrap-content(", "    [#" .. unique_name .. "],", "    [" }),
		i(2, ""),    -- Second stop
		t({ "],", "    column-gutter: 1em,", ")" }),
	}

	return sn(nil, nodes)
end

local function get_parent_dir_name()
	-- Get the full path of the current buffer's file
	local file_path = vim.api.nvim_buf_get_name(0)

	if file_path == "" then
		return nil
	end

	local dir_path = vim.fn.fnamemodify(file_path, ":p:h")

	if dir_path == vim.fn.fnamemodify(dir_path, ":p:h:h") then
		return dir_path
	end

	local parent_dir_name = vim.fn.fnamemodify(dir_path, ":t")

	return parent_dir_name
end

function M.generate_template(_, _)
	local dir_path = get_parent_dir_name()
	local dir_map = {
		["emat"] = "Grundl. Mathematik WW",
		["cogo"] = "Corporate Governance",
		["ams"] = "All. Meth. Statistik",
		["e101"] = "Einführung VWL",
		["macr"] = "Makroökonomik",
	}
	local dir_name = dir_map[dir_path]
	return sn(nil, { t(dir_name) })
end

function M.get_dynamic_project_name()
	local filename = vim.fn.expand("%:t")

	local dynamic_templates = {
		["^hw(%d+)%.?.*$"] = "Homework %s",
		["^tut(%d+)%.?.*$"] = "Tutorium %s",
		["^mock(%d+)%.?.*$"] = "Mock Exam %s",
		["^lec(%d+)%.?.*$"] = "Lecture %s",
		["^q(%d+)%.?.*$"] = "Quiz %s",
		["^abg(%d+)%.?.*$"] = "Abgabe %s",
	}

	for pattern, template in pairs(dynamic_templates) do
		local captured_number = string.match(filename, pattern)

		if captured_number then
			return string.format(template, captured_number)
		end
	end

	local exact_names = {
		["format"] = "Formatting Code",
		["README"] = "Project Overview",
		["main"] = "Main Entry Point",
	}

	local base_name = vim.fn.fnamemodify(filename, ":r")

	for name, result in pairs(exact_names) do
		if base_name == name then
			return result
		end
	end

	local file_path = vim.api.nvim_buf_get_name(0)

	if file_path == "" then
		return nil
	end

	local dir_path = vim.fn.fnamemodify(file_path, ":p:h")

	if dir_path == vim.fn.fnamemodify(dir_path, ":p:h:h") then
		return dir_path
	end

	local parent_dir_name = vim.fn.fnamemodify(dir_path, ":t")

	return parent_dir_name
end

return M
