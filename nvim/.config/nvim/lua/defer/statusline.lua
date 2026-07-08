local M = {}
local opts = {
	mode = 1,
}
local modes = {
	["n"] = { "NORMAL", "N" },
	["no"] = { "O-PENDING", "OP" },
	["nov"] = { "O-PENDING", "OP" },
	["noV"] = { "O-PENDING", "OP" },
	["no\22"] = { "O-PENDING", "OP" },
	["niI"] = { "NORMAL", "N" },
	["niR"] = { "NORMAL", "N" },
	["niV"] = { "NORMAL", "N" },
	["nt"] = { "NORMAL", "N" },
	["v"] = { "VISUAL", "V" },
	["vs"] = { "VISUAL", "V" },
	["V"] = { "V-LINE", "V-L" },
	["Vs"] = { "V-LINE", "V-L" },
	["\22"] = { "V-BLOCK", "V-B" },
	["\22s"] = { "V-BLOCK", "V-B" },
	["s"] = { "SELECT", "S" },
	["S"] = { "S-LINE", "S-L" },
	["\19"] = { "S-BLOCK", "S-B" },
	["i"] = { "INSERT", "I" },
	["ic"] = { "INSERT", "I" },
	["ix"] = { "INSERT", "I" },
	["R"] = { "REPLACE", "R" },
	["Rc"] = { "REPLACE", "R" },
	["Rx"] = { "REPLACE", "R" },
	["Rv"] = { "V-REPLACE", "V-R" },
	["Rvc"] = { "V-REPLACE", "V-R" },
	["Rvx"] = { "V-REPLACE", "V-R" },
	["c"] = { "COMMAND", "C" },
	["cv"] = { "EX", "EX" },
	["r"] = { "REPLACE", "R" },
	["rm"] = { "MORE", "M" },
	["r?"] = { "CONFIRM", "?" },
	["!"] = { "SHELL", "SH" },
	["t"] = { "TERMINAL", "T" },
}

local rainbow_colors = {
	n = "Function", -- Usually Blue
	i = "String", -- Usually Green
	v = "Statement", -- Usually Purple/Yellow
	V = "Statement",
	["\22"] = "Statement",
	R = "ErrorMsg", -- Usually Red
	c = "WarningMsg", -- Usually Orange
	t = "Directory", -- Usually Blue/Cyan
}

local hl_norm = "Statusline"
local hl_mode = "StatuslineMode"

local function mode()
	local mode_code = vim.api.nvim_get_mode().mode
	local prefix = mode_code:sub(1, 1)
	local hl_name = rainbow_colors[prefix] or "ModeMsg"
	local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
	vim.api.nvim_set_hl(
		0,
		"StatuslineMode",
		vim.tbl_extend("force", hl, { reverse = true, bold = true })
	)
	local m = modes[mode_code] or { mode_code, mode_code }
	local _mode = m[opts.mode or 1] or mode_code
	return string.format("%%#%s# %s %%*", hl_mode, _mode)
end

local function spell(winid, bufnr)
	if not vim.wo[winid].spell then
		return ""
	end

	local spelllang = vim.bo[bufnr].spelllang
	local fmts = string.gsub(spelllang, ",", "/"):upper()
	return string.format("%%#%s#[%s] %%*", hl_mode, fmts)
end

local function file(bufnr, hl)
	hl = hl or hl_norm
	local path = vim.api.nvim_buf_get_name(bufnr)
	local fname = vim.fn.fnamemodify(path, ":t")
	if fname == "" then
		fname = "[No Name]"
	end
	local mod = vim.bo[bufnr].modified and " [+]" or ""
	return string.format("%%#%s# %s %%*", hl, fname .. mod)
end

local function file_info(bufnr, hl)
	hl = hl or hl_norm
	local ft = vim.bo[bufnr].filetype
	local path = vim.api.nvim_buf_get_name(bufnr)
	local perm = ""
	if path ~= "" then
		perm = vim.fn.getfperm(path)
	end
	return string.format("%%#%s# %s %s %%*", hl, ft, perm)
end

local function wordcount(bufnr, hl)
	hl = hl or hl_norm
	local fts = { "markdown", "typst", "text" }
	if vim.tbl_contains(fts, vim.bo[bufnr].filetype) then
		local wc = vim.api.nvim_buf_call(bufnr, function()
			return vim.fn.wordcount()["words"]
		end)
		return string.format("%%#%s# %s words %%*", hl, wc)
	end
	return ""
end

local function position(winid, bufnr, hl)
	hl = hl or hl_norm
	return vim.api.nvim_win_call(winid, function()
		local cur_line = vim.fn.line(".")
		local total_lines = vim.api.nvim_buf_line_count(bufnr)
		local cur_col = vim.fn.virtcol(".")
		local total_cols = math.max(0, vim.fn.virtcol("$") - 1)
		local lines = cur_line .. "/" .. total_lines
		local cols = cur_col .. ":" .. total_cols
		return string.format("%%#%s# %s  %s %%*", hl, lines, cols)
	end)
end

local function diagnostics(bufnr)
	local counts = { ERROR = 0, WARN = 0, HINT = 0, INFO = 0 }
	for _, d in ipairs(vim.diagnostic.get(bufnr)) do
		local s = vim.diagnostic.severity[d.severity]
		if s then
			counts[s] = counts[s] + 1
		end
	end
	local parts = {}
	local severities = { "ERROR", "WARN", "INFO", "HINT" }
	for _, sev in ipairs(severities) do
		local c = counts[sev]
		if c > 0 then
			local letter = sev:sub(1, 1)
			local name = letter .. sev:sub(2):lower()
			local hl = "Diagnostic" .. name
			table.insert(parts, string.format("%%#%s#%s:%d%%*", hl, letter, c))
		end
	end
	if #parts > 0 then
		return " " .. table.concat(parts, " ")
	end
	return ""
end

function M.render()
	local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_win_get_buf(winid)

	local is_active = (winid == vim.api.nvim_get_current_win())
	local hl = is_active and hl_norm or "StatusLineNC"

	local buftype = vim.bo[bufnr].buftype
	local special = {
		terminal = {
			mode(),
			string.format(
				"%%#%s# %s %%*",
				hl,
				vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
			),
		},
		nofile = {
			string.format("%%#%s# Scratch %%*", hl),
		},
		help = {
			" HELP:",
			string.format(
				"%%#%s# %s %%*",
				hl,
				vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
			),
		},
		quickfix = {
			string.format(
				"%%#%s# %s %%*",
				hl,
				(function()
					local title = vim.fn.getloclist(winid, { title = 1 }).title
					if not title or title == "" then
						title = vim.fn.getqflist({ title = 1 }).title
					end
					if not title or title == "" then
						title = "Quickfix"
					end
					return title
				end)()
			),
		},
	}
	if special[buftype] ~= nil then
		return table.concat(special[buftype])
	end

	if not is_active then
		return table.concat({
			file(bufnr, hl),
			"%=",
			position(winid, bufnr, hl),
		})
	end

	return table.concat({
		mode(),
		spell(winid, bufnr),
		file(bufnr, hl),
		diagnostics(bufnr),
		"%=",
		wordcount(bufnr, hl),
		file_info(bufnr, hl),
		position(winid, bufnr, hl),
	})
end

vim.o.statusline = "%!v:lua.require('defer.statusline').render()"

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.wo.statusline = "%!v:lua.require('defer.statusline').render()"
	end,
})

return M
