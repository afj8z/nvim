-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	pattern = "*",
	desc = "highlight selection on yank",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 200,
			visual = true,
		})
	end,
})

-- Jump to previous cursor position of last session
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

-- close built-in buffers with q
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
	desc = "Close with <q>",
	pattern = {
		"help",
		"man",
		"qf",
		"query",
		"scratch",
		"spectre_panel",
		"quickfix-list",
		"quickfix",
		"diagnostics",
	},
	callback = function(args)
		vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = args.buf })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("close_oil_with_q", { clear = true }),
	desc = "Close oil buffer with <q> ",
	pattern = {
		"oil",
	},
	callback = function(args)
		vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = args.buf })
	end,
})

-- Natural typing format options
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
	command = "wincmd =",
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
	group = vim.api.nvim_create_augroup("autoclose", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.o.buftype == "quickfix" then
			if vim.fn.winbufnr(2) == -1 then
				vim.cmd.quit({ bang = true })
			end
		end
	end,
	once = true,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
	group = vim.api.nvim_create_augroup("custom-term-open", {}),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.scrolloff = 0
		vim.cmd("startinsert")
		vim.bo.filetype = "terminal"
	end,
})

vim.api.nvim_create_autocmd(
	{ "BufEnter", "BufWinEnter", "WinEnter", "TermOpen", "TermEnter" },
	{
		group = vim.api.nvim_create_augroup("Term-Insert", { clear = true }),
		pattern = "term://*",
		command = "startinsert",
	}
)

-- vim.api.nvim_create_autocmd("ModeChanged", {
-- 	pattern = "*",
-- 	callback = function()
-- 		if
-- 			(
-- 				(vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n")
-- 				or vim.v.event.old_mode == "i"
-- 			)
-- 			and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
-- 			and not require("luasnip").session.jump_active
-- 			and not require("luasnip").in_snippet()
-- 		then
-- 			require("luasnip").unlink_current()
-- 		end
-- 	end,
-- })
