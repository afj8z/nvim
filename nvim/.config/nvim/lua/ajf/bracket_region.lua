local M = {}
-- Disable builtin matchparens plugin
vim.g.loaded_matchparen = 1

local ns = vim.api.nvim_create_namespace("bracket-region")

-- map of bracket pairs
local pairs_map = {
	["("] = ")",
	["["] = "]",
	["{"] = "}",
	[")"] = "(",
	["]"] = "[",
	["}"] = "{",
	["<"] = ">",
	[">"] = "<",
}

---Checks if a 1-based buffer position is inside a string or comment.
---Can be called with (lnum, col) or with no args (uses vim.fn.line/col).
---@param lnum number?: 1-based line number (optional)
---@param col number?: 1-based byte column (optional)
---@return boolean: true if inside string/comment, false otherwise
local function is_in_syntax(lnum, col)
	local l = lnum or vim.fn.line(".")
	local c = col or vim.fn.col(".")

	local parser = vim.treesitter.get_parser(0)
	if not parser then
		return false
	end

	local node = vim.treesitter.get_node({ bufnr = 0, pos = { l - 1, c - 1 } })
	if not node then
		return false
	end

	local current_node = node
	while current_node do
		local node_type = current_node:type()
		if node_type:find("string") or node_type:find("comment") then
			return true
		end
		current_node = current_node:parent()
	end

	return false
end

-- return row,col (0-based) of the matching bracket, or nil
local function find_match(row, col, ch)
	local open_pat, close_pat, flags

	local function lit(c)
		return "\\V" .. c
	end

	if ch == "(" or ch == "[" or ch == "{" or ch == "<" then
		open_pat, close_pat, flags = lit(ch), lit(pairs_map[ch]), "W"
	elseif ch == ")" or ch == "]" or ch == "}" or ch == ">" then
		open_pat, close_pat, flags = lit(pairs_map[ch]), lit(ch), "bW"
	else
		return nil
	end

	local skip_arg = is_in_syntax

	local view = vim.fn.winsaveview()
	pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, col })
	local pos = vim.fn.searchpairpos(open_pat, "", close_pat, flags, skip_arg)
	vim.fn.winrestview(view)

	if type(pos) == "table" and pos[1] and pos[1] > 0 then
		return pos[1] - 1, pos[2] - 1
	end
	return nil
end

local function get_char_at(row, col)
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
	if col < 0 or col >= #line then
		return nil
	end
	return line:sub(col + 1, col + 1)
end

function M.highlight_between()
	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

	local mode = vim.api.nvim_get_mode().mode
	if not (mode == "n" or mode == "i") then
		return
	end

	local pos = vim.api.nvim_win_get_cursor(0)
	local row, col = pos[1] - 1, pos[2]

	local ch = get_char_at(row, col)
	if not pairs_map[ch or ""] then
		ch = get_char_at(row, col - 1)
		if pairs_map[ch or ""] then
			col = col - 1
		else
			return
		end
	end

	if is_in_syntax(row + 1, col + 1) then
		return
	end

	local mr, mc = find_match(row, col, ch)
	if not mr then
		return
	end

	-- Highlight the bracket region
	local sr, sc, er, ec
	if ch == "(" or ch == "[" or ch == "{" or ch == "<" then
		sr, sc = row, col + 1
		er, ec = mr, mc
	else
		sr, sc = mr, mc + 1
		er, ec = row, col
	end

	if (er < sr) or (er == sr and ec < sc) then
		sr, er = er, sr
		sc, ec = ec, sc
	end
	if not (sr == er and ec <= sc) then
		vim.api.nvim_buf_set_extmark(0, ns, sr, sc, {
			end_row = er,
			end_col = ec,
			hl_group = "BracketRegion",
			hl_eol = true,
			priority = 200,
		})
	end

	-- Highlight the brackets themselves
	vim.api.nvim_buf_set_extmark(0, ns, row, col, {
		end_row = row,
		end_col = col + 1,
		hl_group = "MatchParen",
		priority = 190,
	})
	vim.api.nvim_buf_set_extmark(0, ns, mr, mc, {
		end_row = mr,
		end_col = mc + 1,
		hl_group = "MatchParen",
		priority = 190,
	})
end

function M.setup()
	local aug1 = vim.api.nvim_create_augroup("BracketRegionHL", { clear = true })
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = aug1,
		callback = M.highlight_between,
	})

	local aug2 = vim.api.nvim_create_augroup("BracketRegionHL_Clear", { clear = true })
	vim.api.nvim_create_autocmd({ "BufLeave", "InsertLeave" }, {
		group = aug2,
		callback = function()
			pcall(vim.api.nvim_buf_clear_namespace, 0, ns, 0, -1)
		end,
	})
end

return M
