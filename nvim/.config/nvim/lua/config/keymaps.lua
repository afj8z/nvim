local keyfunc = require("ajf.userfunc")
local utils = require("ajf.utils")
local map = vim.keymap.set
local nmap = utils.nmap
local vmap = utils.vmap
local imap = utils.imap
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
nmap("-", "<cmd>resize -5<CR>")
nmap("+", "<cmd>resize +5<CR>")

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

nmap("x", '"_x')
nmap("s", '"_s')
nmap("X", '"_X')

nmap("rw", "viwp", {
	desc = "replace a word with yanked text",
})
nmap("S", "ciw")
nmap("<leader>p", ":TypstPreviewToggle<CR>")

map("t", "<esc>", "<c-\\><c-n>")
map("t", "<C-k>", function()
	vim.cmd.wincmd("k")
end)
nmap("<leader>T", keyfunc.toggle_terminal)

nmap("<C-a>", keyfunc.toggle_boolean_or_increment, {
	noremap = true,
	silent = true,
	desc = "Increment number or toggle (true|false)",
})

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
		vim.api.nvim_feedkeys(key, "m", true)
	end
end

nmap("<leader>m", numr_calc)

-- Auto-pairs logic with escape closing/ insert closing
local npairs = {
	{ "(", ")" },
	{ "{", "}" },
	{ "[", "]" },
	{ "[", "]" },
	{ '"', '"' },
}

for _, trigger in pairs(npairs) do
	local t1 = trigger[1]
	local t2 = trigger[2]

	local function jump_pair()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local col = cursor[2]
		local line = vim.api.nvim_get_current_line()
		local char = line:sub(col + 1, col + 1)
		if char == t2 then
			return true
		end
		return false
	end

	local function condition()
		local line = vim.api.nvim_get_current_line()
		local _, col = unpack(vim.api.nvim_win_get_cursor(0))
		local eol = string.sub(line, col + 1)

		if t1 == t2 then
			local _, count = string.gsub(line, "%" .. t1, "")
			return count % 2 == 0
		end

		if not string.match(eol, "%" .. t2) then
			return true
		end

		local _, open_count = string.gsub(line, "%" .. t1, "")
		local _, close_count = string.gsub(line, "%" .. t2, "")

		return open_count >= close_count
	end

	vim.keymap.set("i", t1, function()
		if t1 == t2 and jump_pair() then
			return "<Right>"
		elseif condition() then
			return t1 .. t2 .. "<Left>"
		else
			return t1
		end
	end, { expr = true, replace_keycodes = true })

	if t1 ~= t2 then
		vim.keymap.set("i", t2, function()
			if jump_pair() then
				return "<Right>"
			else
				return t2
			end
		end, { expr = true, replace_keycodes = true })
	end
end

local spairs = {
	{ "(", ")" },
	{ "{", "}" },
	{ "[", "]" },
	{ "[", "]" },
	{ '"', '"' },
	{ "$", "$" },
	{ "<", ">" },
	{ "'", "'" },
	{ "`", "`" },
}

local function sur_wrd(open_c, close_c)
	local function condition()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))

		for r = row, 1, -1 do
			local line = vim.api.nvim_buf_get_lines(0, r - 1, r, false)[1]

			local start_col = (r == row) and (col + 1) or #line

			for c = start_col, 1, -1 do
				if string.sub(line, c, c):match("%S") then
					return { r, c - 1 }
				end
			end
		end
	end
	local target_pos = condition()
	if not target_pos then
		return vim.print("No Candidate Word found")
	end
	local row, col = unpack(target_pos)

	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

	local eol = string.sub(line, col + 1)
	local sol = string.sub(line, 0, col + 1)

	local sow = string.gsub(sol, ".*%s", "")
	local eow = string.gsub(eol, "%s.*", "")
	local range = {
		start = (col - string.len(sow)),
		fin = (col + string.len(eow)),
	}
	local word = string.sub(sow, 0, -2) .. eow
	local re_line = string.sub(line, 0, range.start + 1)
		.. open_c
		.. word
		.. close_c
		.. string.sub(line, range.fin + 1)

	vim.api.nvim_buf_set_lines(0, row - 1, row, false, { re_line })
end

for _, trigger in pairs(spairs) do
	local t1 = trigger[1]
	local t2 = trigger[2]
	nmap("<leader>" .. t1, function()
		sur_wrd(t1, t2)
	end)
	nmap("<leader>" .. t2, function()
		sur_wrd(t1, t2)
	end)
end
