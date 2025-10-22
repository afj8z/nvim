local keyfunc = require("ajf.keyfunc")
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

local temap = function(lhs, rhs, opt)
	vim.keymap.set("t", lhs, rhs, opt)
end

local onoremap = function(lhs, rhs, opt)
	vim.keymap.set("o", lhs, rhs, opt)
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "
nmap("<leader>", "<nop>")
vmap("<leader>", "<nop>")

nmap("<leader>o", ":update<CR> :source<CR>", { desc = "Source nvim config changes" })
nmap("<leader>w", "<Cmd>write<CR>")
nmap("<leader>q", ":quit<CR>")
map({ "n", "v" }, "<leader>c", "1z=")
map({ "n", "v" }, "<leader>n", ":norm ")

vmap("<leader>s", [["hy:%s/<C-r>h/<C-r>h/gI<Left><Left><left>]])
nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { silent = false })

map({ "n", "v", "x" }, "<leader>li", ":set invlist<CR>", { desc = "Toggle [l]istchars in/visible" })
map({ "n", "v", "x" }, "<leader>/", ":noh<CR>")

nmap("<leader>e", ":Oil<CR>")
nmap("<leader>lf", vim.lsp.buf.format)

-- buffer nav
nmap("<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
nmap("<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
nmap("<leader>bd", ":bdelete<CR>", { desc = "Previous buffer" })
nmap("<leader>bb", ":e #<CR>")
nmap("<leader>bs", ":vert sf #<CR>")

-- improve commands with motions
nmap("n", "nzzzv")
nmap("N", "Nzzzv")

-- smarter indenting
nmap("<", "<<")
nmap(">", ">>")
vmap("<", "<gv")
vmap(">", ">gv")

-- visual chars in line
vmap("iV", "^vvg_")

-- yank visible text
nmap("yY", "v^vvg_y")

map({ "n", "v", "o" }, "H", "^")
map({ "n", "v", "o" }, "L", "$")

nmap("gb", "<C-w>w")
nmap("gB", "<C-w>W")

nmap("x", '"_x')
nmap("s", '"_s')
nmap("X", '"_X')

nmap("rw", "viwpyiw", { desc = "replace a word with yanked text, dont write to register" })
nmap("<leader>p", ":TypstPreviewToggle<CR>")

nmap("S", "ciw")
nmap("cis", 'ci"')
nmap("ciS", "ci'")

vmap("si'", "c''<Esc>P", { desc = "Surround with single quotes" })
vmap('<leader>"', 'c""<Esc>P', { desc = "Surround with double quotes" })
vmap("<leader>(", "c()<Esc>P", { desc = "Surround with parentheses" })
vmap("<leader>[", "c[]<Esc>P", { desc = "Surround with brackets" })
vmap("<leader>{", "c{}<Esc>P", { desc = "Surround with braces" })

-- my functions in ../ajf/keyfunc.lua
nmap("<Leader>m", keyfunc.run_file)

nmap("<leader>!", keyfunc.open_root_todo, {
	desc = "Open project/global todo file",
})

nmap("<C-A>", keyfunc.toggle_boolean_or_increment, {
	noremap = true,
	silent = true,
	desc = "Increment number or toggle boolean",
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
