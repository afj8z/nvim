local keyfunc = require("ajf.userfunc")
local utils = require("ajf.utils")
local map = vim.keymap.set
local nmap = utils.nmap
local vmap = utils.vmap
local k = vim.keycode

-- set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
map({ "n", "v" }, "<leader>", "<nop>")

-- editor operations
-- nmap("<leader>o", ":update<CR> :source<CR>")
nmap("<leader>w", "<Cmd>write<CR>", { silent = true })
nmap("<leader>q", "<Cmd>:quit<CR>")

-- spell
map({ "n", "v" }, "<leader>c", "1z=")

-- editor commands
map({ "n", "v" }, "<leader>n", ":norm ")

nmap("<CR>", function()
	---@diagnostic disable-next-line: undefined-field
	if vim.v.hlsearch == 1 then
		vim.cmd.nohl()
		return ""
	else
		return k("<CR>")
	end
end, { expr = true })

-- file navigation
nmap("<leader>e", "<cmd>Oil<CR>", { silent = true })

-- buffer nav
nmap("<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
nmap("<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
nmap(
	"<leader>bd",
	keyfunc.close_buf_keep_layout,
	{ desc = "Close buffer, keep layout" }
)
nmap("<leader>bb", ":e #<CR>")
nmap("<leader>bs", ":vert sf #<CR>")
nmap("<leader>bx", keyfunc.smart_close_buffers, { desc = "Close hidden buffers" })

-- tab nav
nmap("<leader>td", "<cmd>tabclose<CR>")
nmap("<leader>tt", "<cmd>tabnew<CR>")

-- win resizing
nmap("<C-h>", "<C-w>h")
nmap("<C-j>", "<C-w>j")
nmap("<C-k>", "<C-w>k")
nmap("<C-l>", "<C-w>l")
nmap(">", "<cmd>vertical resize +8<CR>")
nmap("<", "<cmd>vertical resize -8<CR>")
nmap("-", "<cmd>resize +5<CR>")
nmap("+", "<cmd>resize -5<CR>")

-- improve commands with motions
nmap("n", "nzzzv")
nmap("N", "Nzzzv")
nmap("<C-u>", "<C-u>zzzv")
nmap("<C-d>", "<C-d>zzzv")
nmap("<C-f>", "<C-f>zzzv")
nmap("<C-b>", "<C-b>zzzv")

---Text Blocks
-- smarter indenting
vmap("<", "<gv")
vmap(">", ">gv")
vmap("J", ":m '>+1<CR>gv=gv")
vmap("K", ":m '<-2<CR>gv=gv")

map({ "n", "v", "o" }, "H", "^")
map({ "n", "v", "o" }, "L", "$")

nmap("x", '"_x')
nmap("s", '"_s')
nmap("X", '"_X')

nmap("rw", "viwp", {
	desc = "replace a word with yanked text",
})
nmap("S", "ciw")
nmap("<leader>p", ":TypstPreviewToggle<CR>")

nmap("<C-a>", keyfunc.toggle_boolean_or_increment, {
	noremap = true,
	silent = true,
	desc = "Increment number or toggle (true|false)",
})
