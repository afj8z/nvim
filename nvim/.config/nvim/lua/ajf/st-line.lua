-- inspired by https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/statusline.lua
-- much of it copied and adjusted for my case
local M = {}
local colors = require("colors")
local icons = require("ajf.icons")
local internal_fts = {
	help = true,
	checkhealth = true,
	man = true,
	lazy = true,
	DiffviewFiles = true,
	DiffviewFileHistory = true,
	OverseerForm = true,
	OverseerList = true,
	["ccc-ui"] = true,
	["dap-view"] = true,
	["grug-far"] = true,
	codecompanion = true,
	lazyterm = true,
	minifiles = true,
	TelescopePrompt = true,
}

vim.g.qf_disable_statusline = 1

---Remove highlight groups
---@param str string
---@return string
local function strip_highlights(str)
	if not str then
		return ""
	end
	-- Removes highlight groups like %#HlGroup#
	str = str:gsub("%%#[^#]+#", "")
	-- Removes highlight resets like %*
	str = str:gsub("%%%*", "")
	return str
end

---@param components string[]
---@return string
local function concat_components(components)
	return vim.iter(components):skip(1):fold(components[1], function(acc, component)
		return #component > 0 and string.format("%s  %s", acc, component) or acc
	end)
end

local progress_status = {}

vim.api.nvim_create_autocmd("LspProgress", {
	group = vim.api.nvim_create_augroup("stline", { clear = true }),
	desc = "Update LSP progress in statusline",
	pattern = { "begin", "end" },
	callback = function(args)
		if not args.data then
			return
		end

		local client = vim.lsp.get_client_by_id(args.data.client_id)
		-- Add a guard in case client is not found
		if not client then
			return
		end
		progress_status = {
			client = client.name,
			kind = args.data.params.value.kind,
			title = args.data.params.value.title,
		}

		if progress_status.kind == "end" then
			progress_status.title = nil
			-- Wait a bit before clearing the status.
			vim.defer_fn(function()
				vim.cmd.redrawstatus()
			end, 3000)
		else
			vim.cmd.redrawstatus()
		end
	end,
})

--Statusline Component functions
--- @return string
function M.lsp_active()
	if not rawget(vim, "lsp") then
		return ""
	end

	local ignore_list = {
		copilot = true,
		ruff = true,
		stylua = true,
	}

	local current_buf = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = current_buf })

	if #clients == 0 then
		return "[No LSP]"
	end

	local client_names = {}
	for _, client in ipairs(clients) do
		if client and client.name and not ignore_list[client.name] then
			table.insert(client_names, client.name)
		end
	end

	if #client_names == 0 then
		return ""
	end

	local display_str
	if #client_names == 1 then
		display_str = client_names[1] -- Show the single name
	else
		display_str = string.format("%d clients", #client_names) -- Show the count
	end

	-- Check for progress from a *non-ignored* client
	if progress_status.title and progress_status.client and not ignore_list[progress_status.client] then
		return string.format(
			"%%#StatuslineTitle#%s (%s: %s)",
			display_str,
			progress_status.client,
			progress_status.title
		)
	end

	-- No progress, or progress is from an ignored client. Just show the names/count.
	return string.format("%%#StatuslineTitle#%s", display_str)
end

--- The buffer's filetype.
---@return string
function M.filetype_component()
	local filetype = vim.bo.filetype
	if filetype == "" or filetype == nil then
		filetype = "[No Name]"
	end

	return string.format("%%#StatuslineTitle#%s", filetype)
end

local last_diagnostic_component = ""
--- Diagnostic counts in the current buffer.
---@return string
function M.diagnostics_component()
	-- Use the last computed value if in insert mode.
	if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
		return last_diagnostic_component
	end

	local counts = vim.iter(vim.diagnostic.get(0)):fold({
		ERROR = 0,
		WARN = 0,
		HINT = 0,
		INFO = 0,
	}, function(acc, diagnostic)
		local severity = vim.diagnostic.severity[diagnostic.severity]
		acc[severity] = acc[severity] + 1
		return acc
	end)

	local parts = vim.iter(counts)
		:map(function(severity, count)
			if count == 0 then
				return nil
			end

			local hl = "Diagnostic" .. severity:sub(1, 1) .. severity:sub(2):lower()
			return string.format("%%#%s#%s %d", hl, icons.diagnostics[severity], count)
		end)
		:totable()

	return table.concat(parts, " ")
end

---@return string
function M.filename()
	local fname = vim.fn.expand("%:t")
	if fname == "" or fname == nil then
		fname = "[No Name]"
	end

	local modified_indicator = ""
	if vim.bo.modified then
		modified_indicator = " [+]"
	end

	return fname .. modified_indicator .. " "
end

---@return string
function M.filename_inactive()
	local fname = vim.fn.expand("%:t")
	if fname == "" or fname == nil then
		return "[No Name]"
	end
	return string.format("%%#StatusLineNC#%s ", fname)
end

--- The current line, total line count, and column position.
---@return string
function M.position_component()
	local line = vim.fn.line(".")
	local line_count = vim.api.nvim_buf_line_count(0)
	local col = vim.fn.virtcol(".")

	return table.concat({
		string.format("%%#StatuslineTitle#%d", line),
		string.format("%%#StatuslineItalic#/%d-%d", line_count, col),
	})
end

---Renders the statusline for quickfix/location lists.
---@return string
function M.render_qf()
	local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
	local title = ""

	if wininfo.loclist == 1 then
		title = vim.fn.getloclist(0, { title = 1 }).title
	elseif wininfo.quickfix == 1 then
		title = vim.fn.getqflist({ title = 1 }).title
	end

	if title == "" or title == nil then
		title = "[Quickfix List]" -- Fallback
	end

	local pos_component = M.position_component()

	local pos_text = strip_highlights(pos_component)

	-- Combine into a single string.format call
	return string.format("%%#StatusLineReversed#%s %%=%s %%*", title, pos_text)
end

---Renders a minimal statusline for internal buffers (help, lazy, etc.)
---@return string
function M.render_internal()
	local ft_component = M.filetype_component()
	local pos_component = M.position_component()

	local pos_text = strip_highlights(pos_component)
	local ft_text = strip_highlights(ft_component)

	-- Combine into a single string.format call
	return string.format("%%#StatusLineReversed#%s %%=%s %%*", ft_text, pos_text)
end

---Renders the statusline
---@return string
function M.render()
	local ft = vim.bo.filetype

	-- Oil buffer
	if ft == "oil" or ft == "fzf" then
		local path = vim.fn.expand("%:p")
		return string.format("%%#StatusLineReversed#%s %%= %%*", path)
	end

	-- Quickfix / Location List
	if ft == "qf" then
		local comps = table.concat({
			concat_components({
				M.render_qf(),
			}),
		})
		return string.format("%%#StatusLineReversed#%s %%*", comps)
	end

	-- Other internal buffers (help, lazy, checkhealth, etc.)
	if internal_fts[ft] then
		local comps = table.concat({
			concat_components({
				M.render_internal(), -- Get the 'help' icon/name
			}),
		})
		return string.format("%%#StatusLineReversed#%s %%*", comps)
	end

	return table.concat({
		concat_components({
			M.filename(),
		}),
		"%=",
		"%S ",
		"%#StatusLine#%=",
		concat_components({
			M.lsp_active(),
			M.diagnostics_component(),
			M.position_component(),
		}),
		" ",
	})
end

---Renders the inactive statusline.
---@return string
function M.render_inactive()
	---@return string

	return table.concat({
		M.filename_inactive(),
	})
end

---Renders the statusline for all windows.
---Neovim will call this for each window, setting g:statusline_winid
---to the window-ID it's currently drawing.
function M.render_global()
	local winid = vim.g.statusline_winid

	local active_winid = vim.api.nvim_get_current_win()

	if winid == active_winid then
		return M.render()
	else
		local bufid = vim.api.nvim_win_get_buf(winid)
		if not bufid or not vim.api.nvim_buf_is_valid(bufid) then
			return "%#StatusLineNC#[No Buffer]"
		end
		local fname = vim.api.nvim_buf_get_name(bufid)
		if fname == "" or fname == nil then
			fname = "[No Name]"
		else
			fname = vim.fn.fnamemodify(fname, ":t")
		end
		return string.format("%%#StatusLineNC#%s ", fname)
	end
end

vim.opt.statusline = "%!v:lua.require('ajf.st-line').render_global()"

vim.api.nvim_set_hl(0, "StatusLineReversed", { fg = colors.bg, bg = colors.fg })

return M
