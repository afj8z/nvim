local keyfunc = require("ajf.userfunc")
local utils = require("ajf.utils")
local map = vim.keymap.set
local nmap = utils.nmap
local vmap = utils.vmap
local tmap = utils.tmap
local k = vim.keycode

---leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
map({ "n", "v" }, "<leader>", "<nop>")

---editor operations
nmap("<leader>w", "<Cmd>write<CR>", { silent = true })
nmap("<leader>q", "<Cmd>:quit<CR>")
nmap("<leader>Q", "<Cmd>:qall<CR>")

---editor commands
nmap("<CR>", function()
	if vim.v.hlsearch == 1 then
		vim.cmd.nohl()
		return ""
	else
		return k("<CR>")
	end
end, { expr = true })

---file navigation
nmap("<leader>e", "<cmd>Oil<CR>")

---buffer navigation
nmap("<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
nmap("<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
nmap(
	"<leader>bd",
	keyfunc.close_buf_keep_layout,
	{ desc = "Close buffer, keep layout" }
)

nmap("<leader>bb", ":e #<CR>", { silent = true })
nmap("<leader>bs", ":vert sf #<CR>", { silent = true })
nmap("<leader>bx", keyfunc.smart_close_buffers, { desc = "Close hidden buffers" })
nmap("<leader>l", ":b #<CR>", { silent = true })

---tab navigation
nmap("<leader>t", ":tab sb<CR>")
nmap("<leader>j", ":tabp<CR>")
nmap("<leader>k", ":tabn<CR>")
nmap("<leader>c", ":tabc<CR>")

---win navigation
nmap("<C-h>", "<C-w>h")
nmap("<C-j>", "<C-w>j")
nmap("<C-k>", "<C-w>k")
nmap("<C-l>", "<C-w>l")
nmap("<C-w>h", "<C-w>H")
nmap("<C-w>j", "<C-w>J")
nmap("<C-w>k", "<C-w>K")
nmap("<C-w>l", "<C-w>L")

nmap("<C-S-H>", function()
	keyfunc.resize_win_dir("left", 8)
end)
nmap("<C-S-L>", function()
	keyfunc.resize_win_dir("right", 8)
end)
nmap("<C-S-K>", function()
	keyfunc.resize_win_dir("up", 8)
end)
nmap("<C-S-J>", function()
	keyfunc.resize_win_dir("down", 8)
end)

---improved commands
-- TODO: Should these be moved to nIM.nvim?
-- nav
nmap("n", "nzzzv")
nmap("N", "Nzzzv")
nmap("<C-u>", "<C-u>zzzv")
nmap("<C-d>", "<C-d>zzzv")
nmap("<C-f>", "<C-f>zzzv")
nmap("<C-b>", "<C-b>zzzv")
-- motions
nmap("S", "ciw")
-- void deletions
nmap("x", '"_x')
nmap("s", '"_s')
nmap("X", '"_X')

---Text Blocks
-- smarter indenting
vmap("<", "<gv")
vmap(">", ">gv")
vmap("J", ":m '>+1<CR>gv=gv")
vmap("K", ":m '<-2<CR>gv=gv")

---Terminal Esc -> Normal mode in vim
-- C-[ and other such escapes will be
-- captured by the terminal
tmap("<Esc>", "<C-\\><C-n>")

nmap("cr", "viwp", {
	desc = "replace a word with yanked text",
})

nmap("<C-a>", keyfunc.toggle_boolean_or_increment, {
	noremap = true,
	silent = true,
	desc = "Increment number or toggle (true|false)",
})

nmap("<leader>yf", keyfunc.copy_fname)

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

	-- Default to double quote if none found on the current line
	best_quote = best_quote or '"'

	return (inner and "i" or "a") .. best_quote
end

map({ "x", "o" }, "iq", function()
	return smart_quote(true)
end, { expr = true, desc = "Inner generic quote" })
map({ "x", "o" }, "aq", function()
	return smart_quote(false)
end, { expr = true, desc = "Around generic quote" })
