local keyfunc = require("ajf.keyfunc")
local metaf = require("ajf.metafiles")
local surround = require("ajf.surroundop")
local map = vim.keymap.set

local nmap = function(lhs, rhs, opt)
	vim.keymap.set("n", lhs, rhs, opt)
end

local imap = function(lhs, rhs, opt)
	vim.keymap.set("i", lhs, rhs, opt)
end

local vmap = function(lhs, rhs, opt)
	vim.keymap.set("v", lhs, rhs, opt)
end

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
map({ "n", "v" }, "<leader>", "<nop>")

nmap("<leader>o", ":update<CR> :source<CR>")
nmap("<leader>w", "<Cmd>write<CR>")
nmap("<leader>q", "<Cmd>:quit<CR>")
nmap("<leader>Q", "<Cmd>:wqa<CR>")
map({ "n", "v" }, "<leader>c", "1z=")
map({ "n", "v" }, "<leader>n", ":norm ")

vmap("<leader>s", [["hy:%s/<C-r>h/<C-r>h/gI<Left><Left><left>]])
nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { silent = false })

-- clear highlights
map({ "n", "v", "x" }, "<leader>/", ":noh<CR>", { silent = true })

nmap("<leader>e", "<cmd>Oil<CR>", { silent = true })
nmap(
	"<leader>te",
	"<cmd>lua local dir = vim.fn.expand('%:p:h'); vim.cmd('tabnew | Oil ' .. dir)<CR>",
	{ silent = true }
) --!TODO no new tab if file is [No Name]
nmap("<leader>E", "<cmd>tabnew | Oil<CR>", { silent = true })
nmap("<leader>lf", vim.lsp.buf.format)

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

-- win resizing
nmap("<leader>>", "<cmd>vertical resize +8<CR>")
nmap("<leader><", "<cmd>vertical resize -8<CR>")
nmap("<leader>-", "<cmd>resize +5<CR>")
nmap("<leader>+", "<cmd>resize -5<CR>")

-- improve commands with motions
nmap("n", "nzzzv")
nmap("N", "Nzzzv")

-- smarter indenting
nmap("<", "<<")
nmap(">", ">>")
vmap("<", "<gv")
vmap(">", ">gv")

-- yank visible text
nmap("yl", "v^vvg_y")

map({ "n", "v", "o" }, "H", "^")
map({ "n", "v", "o" }, "L", "$")

nmap("gb", "<C-w>w")
nmap("gB", "<C-w>W")

nmap("x", '"_x')
nmap("s", '"_s')
nmap("X", '"_X')

-- ** Text editing **
-- replace a word with yanked text, dont write to register
nmap("rw", "viwpyiw")
nmap("<leader>p", ":TypstPreviewToggle<CR>")
nmap("U", "<C-r>")

nmap("S", "ciw")
nmap("cis", 'ci"', { desc = 'Change in "string"' })
nmap("ciS", "ci'", { desc = "Change in 'String'" })

vmap("<leader>'", "c''<Esc>P", { desc = "Surround with single quotes" })
vmap('<leader>"', 'c""<Esc>P', { desc = "Surround with double quotes" })
vmap("<leader>(", "c()<Esc>P", { desc = "Surround with parentheses" })
vmap("<leader>[", "c[]<Esc>P", { desc = "Surround with brackets" })
vmap("<leader>{", "c{}<Esc>P", { desc = "Surround with braces" })

-- my functions in ../ajf/keyfunc.lua
nmap("<Leader>m", keyfunc.run_file)

nmap("<Leader>L", keyfunc.ToggleCursorLine)

nmap("<leader>!", keyfunc.open_root_todo, {
	desc = "Open project/global todo file",
})

nmap("<C-A>", keyfunc.toggle_boolean_or_increment, {
	noremap = true,
	silent = true,
	desc = "Increment number or toggle boolean",
})

nmap("<leader>0", keyfunc.insert_screenshot, {
	noremap = true,
	silent = true,
	desc = "insert most recent screenshot in filetype dependant format",
})

imap("<C-l>", keyfunc.smart_space_jump, {
	expr = true,
	noremap = true,
	silent = true,
	desc = "Smart jump and space",
})

map({ "n", "v" }, "<leader>r", keyfunc.surround_motion_with, {
	expr = true,
	desc = "Surround motion with character",
})

-- vim.keymap.set("n", "<leader>2", metaf.toggle_notes, { desc = "Toggle notes" })
