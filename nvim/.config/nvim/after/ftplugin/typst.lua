vim.keymap.set("n", "<leader>p", ":TypstPreviewToggle<CR>")
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
			return "<CR>" .. "- "
		end

		if line:match("^%s*$") or line:match("^%S") then
			break
		end
	end

	return "<CR>"
end, { expr = true, buffer = true, replace_keycodes = true })

local wutils = require("ajf.writingutils")
local opts = { buffer = true, silent = true }

local function typst_link_open()
	wutils.link_and_open({
		ext = "typ",
		format = function(text, filename)
			return string.format('#link("%s")[%s]', filename, text)
		end,
	})
end

vim.keymap.set("n", "<leader>gf", function()
	vim.cmd("normal! viW")
	typst_link_open()
end, opts)
vim.keymap.set("x", "<leader>gf", typst_link_open, opts)

local function typst_domain_link()
	wutils.domain_link({
		format = function(domain, url)
			return string.format('#link("%s")[%s]', url, domain)
		end,
	})
end

vim.keymap.set("n", "<leader>cl", function()
	vim.cmd("normal! viW")
	typst_domain_link()
end, opts)
vim.keymap.set("x", "<leader>cl", typst_domain_link, opts)

vim.keymap.set("n", "gf", function()
	wutils.smart_gf({
		pattern = '#link%("([^"]+)"%)%[.-%]',
	})
end, opts)
