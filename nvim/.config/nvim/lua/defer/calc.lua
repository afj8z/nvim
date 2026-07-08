local nmap = require("ajf.utils").nmap

local calc_ns = vim.api.nvim_create_namespace("qalc_inline")

local function numr_calc()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local line = vim.api.nvim_get_current_line()
	local result = vim.trim(vim.fn.system("qalc -t '" .. line .. "'"))
	local nline = "= " .. (result:gsub("\n", " "))

	vim.api.nvim_buf_set_extmark(0, calc_ns, row, 0, {
		virt_text = { { nline, "Comment" } },
		virt_text_pos = "eol",
		id = 1,
	})

	vim.cmd("redraw")

	local key = vim.fn.getcharstr()

	vim.api.nvim_buf_del_extmark(0, calc_ns, 1)

	if key == "\r" or key == "\n" then
		vim.api.nvim_buf_set_lines(0, row + 1, row + 1, false, { nline })
	else
		if key == "\t" then
			result = line .. " = " .. result:gsub("\n", "")
			vim.api.nvim_set_current_line(result)
			vim.api.nvim_win_set_cursor(0, { row + 1, string.len(result) })
		end
		vim.api.nvim_feedkeys(key, "m", true)
	end
end

nmap("<leader>m", numr_calc)
