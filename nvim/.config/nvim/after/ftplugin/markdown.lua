vim.opt.conceallevel = 2

if vim.bo.buftype == "nofile" then
	local vo = {
		opt = {
			wrap = true,
			concealcursor = "ni",
			conceallevel = 1,
		},
	}
	Defer.set.setopts(vo)
end

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

local wutils = require("ajf.writingutils")
local opts = { buffer = true, silent = true }

local function md_link_open()
	wutils.link_and_open({
		ext = "md",
		format = function(text, filename)
			return string.format("[%s](%s)", text, filename)
		end,
	})
end

vim.keymap.set("n", "<leader>gf", function()
	vim.cmd("normal! viW")
	md_link_open()
end, opts)
vim.keymap.set("x", "<leader>gf", md_link_open, opts)

local function md_domain_link()
	wutils.domain_link({
		format = function(domain, url)
			return string.format("[%s](%s)", domain, url)
		end,
	})
end

vim.keymap.set("n", "<leader>cl", function()
	vim.cmd("normal! viW")
	md_domain_link()
end, opts)
vim.keymap.set("x", "<leader>cl", md_domain_link, opts)

vim.keymap.set("n", "gf", function()
	wutils.smart_gf({
		pattern = "%[.-%]%(([^)]+)%)",
	})
end, opts)
