local keyfunc = require("ajf.userfunc")
local utils = require("ajf.utils")
local map = vim.keymap.set
local nmap = utils.nmap
local imap = utils.imap
local vmap = utils.vmap

-- set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
map({ "n", "v" }, "<leader>", "<nop>")

-- editor operations
nmap("<leader>o", ":update<CR> :source<CR>")
nmap("<leader>w", "<Cmd>write<CR>")
nmap("<leader>q", "<Cmd>:quit<CR>")
nmap("<leader>Q", "<Cmd>:wqa<CR>")

-- substitute text
vmap("<leader>s", [["hy:%s/<C-r>h/<C-r>h/gI<Left><Left><left>]])
nmap(
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ silent = false }
)

-- spell
map({ "n", "v" }, "<leader>c", "1z=")

-- editor commands
map({ "n", "v" }, "<leader>n", ":norm ")
nmap("<leader>lf", vim.lsp.buf.format)

-- file navigation
nmap("<leader>e", "<cmd>Oil<CR>", { silent = true })
nmap(
	"<leader>te",
	"<cmd>lua local dir = vim.fn.expand('%:p:h'); vim.cmd('tabnew | Oil ' .. dir)<CR>",
	{ silent = true }
)
nmap("<leader>E", "<cmd>tabnew | Oil<CR>", { silent = true })

-- buffer nav
nmap("<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
nmap("<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
nmap("<leader>bd", ":bdelete<CR>", { desc = "Previous buffer" })
nmap("<leader>bb", ":e #<CR>")
nmap("<leader>bs", ":vert sf #<CR>")

-- tab nav
for i = 1, 8 do
	map({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>")
end
nmap("<leader>td", "<cmd>tabclose<CR>")
nmap("<leader>tt", "<cmd>tabnew<CR>")

-- win resizing
nmap("<leader>>", "<cmd>vertical resize +8<CR>")
nmap("<leader><", "<cmd>vertical resize -8<CR>")
nmap("<leader>-", "<cmd>resize +5<CR>")
nmap("<leader>+", "<cmd>resize -5<CR>")

-- improve commands with motions
nmap("n", "nzzzv")
nmap("N", "Nzzzv")
nmap("<C-u", "<C-u>zzzv")
nmap("<C-d>", "<C-d>zzzv")

-- smarter indenting
nmap("<", "<<")
nmap(">", ">>")
vmap("<", "<gv")
vmap(">", ">gv")

map({ "n", "v", "o" }, "H", "^")
map({ "n", "v", "o" }, "L", "$")

nmap("gb", "<C-w>w")
nmap("gB", "<C-w>W")

nmap("x", '"_x')
nmap("s", '"_s')
nmap("X", '"_X')

-- ** Text editing **
nmap("ryw", "viwpyiw", {
	desc = "replace a word with yanked text, dont write to register",
})
nmap("rw", "viwp", {
	desc = "replace a word with yanked text",
})
nmap("S", "ciw")
nmap("<leader>p", ":TypstPreviewToggle<CR>")

-- custom functions
nmap("<Leader>L", keyfunc.ToggleCursorLine, {
	desc = "toggle highlight full cursor line",
})

nmap("<C-A>", keyfunc.toggle_boolean_or_increment, {
	noremap = true,
	silent = true,
	desc = "Increment number or toggle (true|false)",
})

nmap("<leader>is", keyfunc.insert_screenshot, {
	noremap = true,
	silent = true,
	desc = "insert most recent screenshot in filetype dependant format",
})

imap("<CR>", keyfunc.smart_enter, { noremap = true })
