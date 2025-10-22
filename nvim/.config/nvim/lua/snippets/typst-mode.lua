local M = {}

-- Determines if the cursor is in a math context using Tree-sitter.
function M.is_in_math()
	-- Ensure the Tree-sitter parser is available and active for the buffer.
	local parser = vim.treesitter.get_parser(0, "typst")
	if not parser then
		-- Fallback or simply fail if Tree-sitter is not available.
		return false
	end

	-- Get the syntax tree for the current buffer.
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

		-- The typst parser uses `math.inline` and `math.display` for math blocks.
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

return M
