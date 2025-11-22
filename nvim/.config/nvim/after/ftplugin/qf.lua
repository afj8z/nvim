local function adjust_height(min_height, max_height)
	local height = math.max(math.min(vim.fn.line("$"), max_height), min_height)
	vim.cmd(height .. "wincmd_")
end

adjust_height(2, 9)

vim.opt_local.relativenumber = false
vim.opt_local.hlsearch = false
