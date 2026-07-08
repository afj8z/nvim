local keyfunc = require("ajf.userfunc")
local k = vim.keycode

---leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, "<leader>", "<nop>")

local nmode = {
	{ "<leader>w", "<Cmd>write<CR>", { silent = true } },
	{ "<leader>q", "<Cmd>:qall<CR>" },
	{
		"<CR>",
		function()
			if vim.v.hlsearch == 1 then
				vim.cmd.nohl()
				return ""
			else
				return k("<CR>")
			end
		end,
		{ expr = true },
	},
	{ "<leader>e", "<cmd>Oil<CR>" },
	{ "<leader>k", ":bnext<CR>", { desc = "Next buffer" } },
	{ "<leader>j", ":bprevious<CR>", { desc = "Previous buffer" } },

	{
		"<leader>c",
		keyfunc.close_buf_keep_layout,
		{ desc = "Close buffer, keep layout" },
	},
	{ "<leader>C", ":bd!<CR>", { desc = "Close buffer and window" } },
	{ "<leader>l", ":b #<CR>", { silent = true } },
	{ "<leader>L", ":vert sf #<CR>", { silent = true } },
	{ "<leader>tt", ":tab sb<CR>" },
	{ "<leader>J", ":tabp<CR>" },
	{ "<leader>K", ":tabn<CR>" },
	{ "<leader>tc", ":tabc<CR>" },
	{ "<C-h>", "<C-w>h" },
	{ "<C-j>", "<C-w>j" },
	{ "<C-k>", "<C-w>k" },
	{ "<C-l>", "<C-w>l" },
	{ "<C-w>h", "<C-w>H" },
	{ "<C-w>j", "<C-w>J" },
	{ "<C-w>k", "<C-w>K" },
	{ "<C-w>l", "<C-w>L" },
	{
		"<C-S-H>",
		function()
			keyfunc.resize_win_dir("left", 2)
		end,
	},
	{
		"<C-S-L>",
		function()
			keyfunc.resize_win_dir("right", 2)
		end,
	},
	{
		"<C-S-K>",
		function()
			keyfunc.resize_win_dir("up", 2)
		end,
	},
	{
		"<C-S-J>",
		function()
			keyfunc.resize_win_dir("down", 2)
		end,
	},
	{ "n", "nzzzv" },
	{ "N", "Nzzzv" },
	{ "G", "Gzbzv" },
	{ "<C-u>", "<C-u>zzzv" },
	{ "<C-d>", "<C-d>zzzv" },
	{ "<C-f>", "<C-f>zzzv" },
	{ "<C-b>", "<C-b>zzzv" },
	{ "cc", "ciw" },
	{ "cp", "viwp" },
	{ "x", '"_x' },
	{ "s", '"_s' },
	{ "X", '"_X' },
	{ "cr", "viwp", { desc = "replace a word with yanked text" } },
	{
		"<C-a>",
		keyfunc.toggle_boolean_or_increment,
		{
			noremap = true,
			silent = true,
			desc = "Increment number or toggle (true|false)",
		},
	},
	{ "<leader>yf", keyfunc.copy_fname },
}

for _, key in ipairs(nmode) do
	vim.keymap.set("n", unpack(key))
end

local vmode = {
	{ "<", "<gv" },
	{ ">", ">gv" },
	{ "J", ":m '>+1<CR>gv=gv" },
	{ "K", ":m '<-2<CR>gv=gv" },
}

for _, key in ipairs(vmode) do
	vim.keymap.set("v", unpack(key))
end

---Terminal Esc -> Normal mode in vim
-- C-[ and other such escapes will be
-- captured by the terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

---Text Operator for `'"
local function smart_quote(inner)
	local line = vim.api.nvim_get_current_line()
	local col = vim.fn.col(".")
	local best_quote = nil
	local min_dist = math.huge

	for _, quote in ipairs({ '"', "'", "`" }) do
		local idx = 0
		while true do
			---@diagnostic disable-next-line: cast-local-type
			idx = string.find(line, quote, idx + 1, true)
			if not idx then
				break
			end

			local dist = math.abs(idx - col)
			if dist < min_dist then
				min_dist = dist
				best_quote = quote
			end
		end
	end

	best_quote = best_quote or '"'

	return (inner and "i" or "a") .. best_quote
end

vim.keymap.set({ "x", "o" }, "iq", function()
	return smart_quote(true)
end, { expr = true, desc = "Inner generic quote" })
vim.keymap.set({ "x", "o" }, "aq", function()
	return smart_quote(false)
end, { expr = true, desc = "Around generic quote" })

vim.keymap.set("i", "<C-r>p", "<C-r>+")
