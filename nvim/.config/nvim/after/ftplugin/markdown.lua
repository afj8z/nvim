vim.keymap.set("i", "<CR>", function()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local current_line = vim.api.nvim_get_current_line()

	if current_line:match("^%s*-%s*$") then
		return "<C-u><C-u><CR>"
	end

	local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
	for i = row, 1, -1 do
		local line = lines[i]

		local indent = line:match("^(%s*)%-%s+")
		if indent then
			return "<CR>" .. indent .. "- "
		end

		if line:match("^%s*$") or line:match("^%S") then
			break
		end
	end

	return "<CR>"
end, { expr = true, buffer = true, replace_keycodes = true })
