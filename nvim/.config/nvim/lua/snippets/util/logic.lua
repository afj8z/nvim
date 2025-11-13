local ls = require("luasnip")
local s = ls.snippet

local M = {}
-- Helper function to create an auto-expanding math snippet
function M.is_in_math()
	local parser = vim.treesitter.get_parser(0, "typst")
	if not parser then
		return false
	end

	local tree = parser:parse()[1]
	if not tree then
		return false
	end
	local root = tree:root()

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1

	local current_node = root:descendant_for_range(row, col, row, col)

	while current_node do
		local node_type = current_node:type()

		if node_type == "string" then
			return false
		end

		if node_type:match("^math") then
			return true
		end

		current_node = current_node:parent()
	end

	return false
end

function M.not_in_math()
	return not M.is_in_math()
end

function M.math_snippet(trigger, nodes, opts)
	opts = opts or {}

	local trigger_opts = {
		trig = trigger,
		wordTrig = opts.wordTrig == nil and true or opts.wordTrig,
		priority = opts.priority,
	}

	if opts.regTrig then
		trigger_opts.regTrig = true
	end

	opts.condition = M.is_in_math
	opts.wordTrig = nil
	opts.regTrig = nil
	opts.priority = nil

	return s(trigger_opts, nodes, opts)
end

function M.not_math_s(trigger, nodes, opts)
	opts = opts or {}

	local trigger_opts = {
		trig = trigger,
		wordTrig = opts.wordTrig == nil and true or opts.wordTrig,
	}

	if opts.regTrig then
		trigger_opts.regTrig = true
	end

	opts.condition = M.not_in_math
	opts.wordTrig = nil
	opts.regTrig = nil

	return s(trigger_opts, nodes, opts)
end

return M
