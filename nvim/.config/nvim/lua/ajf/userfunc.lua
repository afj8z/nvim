local M = {}
-- TODO: Much of this should be moved to nIM.nvim

function M.copy_fname()
	local fpath = vim.fn.expand("%:p")
	vim.fn.setreg("+", fpath)
end

--- Toggles boolean words (true/false, True/False) under the cursor.
-- If the word is not a boolean, it performs the default <C-a> action
-- TODO: Move this to nIm.nvim
function M.toggle_boolean_or_increment()
	-- Get word under cursor
	local word = vim.fn.expand("<cword>")

	local toggles = {
		["true"] = "false",
		["false"] = "true",
		["True"] = "False",
		["False"] = "True",
		["TRUE"] = "FALSE",
		["FALSE"] = "TRUE",
	}

	local replacement = toggles[word]

	if replacement then
		local keys = "ciw" .. replacement .. "<Esc>"
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes(keys, true, false, true),
			"n",
			false
		)
	elseif tonumber(word) then
		vim.api.nvim_feedkeys("\x01", "n", false)
	else
	end
end

local function find_word_in_dir(dir)
	for filename in vim.fs.dir(dir) do
		local basename = filename:gsub("%..*$", "")
		if basename:lower() == "local-words" then
			return vim.fs.joinpath(dir, filename)
		end
	end
	return nil
end

function M.get_local_word_dict(default_dict)
	if default_dict == nil then
		default_dict = "~/personal/words.txt"
	end
	local default_fixed = vim.fs.normalize(default_dict)
	local sources = { default_fixed }
	local word_dict_markers = { "local-words.txt" }

	local root_dir = vim.fs.root(0, word_dict_markers)

	if root_dir then
		local word_file = find_word_in_dir(root_dir)

		if word_file then
			table.insert(sources, 1, word_file)
			print("local word dictionary found.")
		else
			print("No local word dictionary found, using general dict.")
		end
	else
		print("No local word dictionary found, using general dict.")
	end
	return sources
end

function M.ToggleCursorLine()
	if vim.o.cursorline then
		vim.o.cursorline = false
		vim.api.nvim_set_hl(0, "CursorLineNr", { link = "LineNr" })
		vim.api.nvim_set_hl(0, "CursorLineSign", { link = "SignColumn" })
	else
		vim.o.cursorline = true
		local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
		local cl_hl = vim.api.nvim_get_hl(0, { name = "CursorLine" })
		if normal_hl and normal_hl.fg and normal_hl.bg then
			vim.api.nvim_set_hl(0, "CursorLineNr", {
				fg = normal_hl.bg,
				bg = normal_hl.fg,
				bold = true,
				force = true, -- Force this to override the link
			})
		end
		if cl_hl and cl_hl.bg then
			vim.api.nvim_set_hl(0, "CursorLineSign", {
				bg = cl_hl.bg,
				force = true,
			})
		end
	end
end

function M.list_snips()
	local filetype = vim.bo.filetype
	local available_snippets = require("luasnip").available()

	if not available_snippets[filetype] then
		print("No LuaSnip snippets found for filetype: " .. filetype)
		return
	end

	local snips_info = {}
	for _, snippet in ipairs(available_snippets[filetype]) do
		table.insert(snips_info, {
			trigger = snippet.trigger,
			name = snippet.name or "N/A",
			type = snippet.snippetType or "snippet",
		})
	end

	if #snips_info == 0 then
		print("No LuaSnip snippets found for filetype: " .. filetype)
		return
	end

	print("Available snippets for filetype: " .. filetype)
	for _, info in ipairs(snips_info) do
		print(
			string.format(
				"- Trigger: %-15s Name: %-30s Type: %s",
				info.trigger,
				info.name,
				info.type
			)
		)
	end
end

---@param toggle_on boolean|nil
---@param lang string|nil
function M.toggle_spell_lang(toggle_on, lang)
	if toggle_on == nil then
		toggle_on = true
	end

	if lang and lang ~= "_" then
		vim.opt.spell = true
		vim.opt.spelllang = lang
		print("Spell enabled (" .. lang .. ")")
		return
	end

	if toggle_on then
		if not vim.opt.spell:get() then
			vim.opt.spell = true
			print("Spell enabled")
		else
			print("Spell is already enabled")
		end
		return
	end

	if not toggle_on then
		if vim.opt.spell:get() then
			vim.opt.spell = false
			print("Spell disabled")
		else
			print("Spell is already disabled")
		end
		return
	end
end

function M.close_buf_keep_layout()
	local curr = vim.api.nvim_get_current_buf()
	if vim.bo[curr].modified then
		vim.notify("Buffer is modified. Save first!", vim.log.levels.WARN)
		return
	end

	local target = vim.fn.bufnr("#")
	if target == -1 or target == curr or not vim.api.nvim_buf_is_loaded(target) then
		local listed = vim.fn.getbufinfo({ buflisted = 1 })
		-- most recent buffer not current
		target = (#listed > 1)
				and listed[#listed - (listed[#listed].bufnr == curr and 1 or 0)].bufnr
			or vim.api.nvim_create_buf(true, false)
	end

	-- swap target into all windows holding the current buffer
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == curr then
			vim.api.nvim_win_set_buf(win, target)
		end
	end

	vim.api.nvim_buf_delete(curr, { force = false })
end

function M.smart_close_buffers()
	local buflist = vim.fn.getbufinfo({ buflisted = 1 })

	if #buflist <= 1 then
		return
	end

	local current_buf = vim.api.nvim_get_current_buf()
	local has_hidden = false

	for _, buf in ipairs(buflist) do
		if buf.hidden == 1 then
			has_hidden = true
			break
		end
	end

	for _, buf in ipairs(buflist) do
		if has_hidden then
			if buf.hidden == 1 then
				pcall(vim.api.nvim_buf_delete, buf.bufnr, { force = false })
			end
		else
			if buf.bufnr ~= current_buf then
				pcall(vim.api.nvim_buf_delete, buf.bufnr, { force = false })
			end
		end
	end

	vim.notify("All hidden buffers closed")
end

function M.resize_win_dir(direction, step)
	step = step or 5

	local is_right_edge = vim.fn.winnr() == vim.fn.winnr("l")
	local is_bottom_edge = vim.fn.winnr() == vim.fn.winnr("j")

	if direction == "left" then
		vim.cmd(
			is_right_edge and ("vertical resize +" .. step)
				or ("vertical resize -" .. step)
		)
	elseif direction == "right" then
		vim.cmd(
			is_right_edge and ("vertical resize -" .. step)
				or ("vertical resize +" .. step)
		)
	elseif direction == "up" then
		vim.cmd(is_bottom_edge and ("resize +" .. step) or ("resize -" .. step))
	elseif direction == "down" then
		vim.cmd(is_bottom_edge and ("resize -" .. step) or ("resize +" .. step))
	end
end

return M
