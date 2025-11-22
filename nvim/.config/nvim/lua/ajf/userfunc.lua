local M = {}

--- Toggles boolean words (true/false, True/False) under the cursor.
-- If the word is not a boolean, it performs the default <C-a> action (increment number).
function M.toggle_boolean_or_increment()
	-- Get the word currently under the cursor
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

	-- CASE 1: The word is a boolean.
	if replacement then
		-- FIX: Use 'ciw' (change inner word) to preserve surrounding whitespace.
		local keys = "ciw" .. replacement .. "<Esc>"
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes(keys, true, false, true),
			"n",
			false
		)

		-- CASE 2: The word is a number.
	elseif tonumber(word) then
		-- FIX: Send the literal terminal code for Ctrl-A ('\x01') to avoid mapping loops.
		-- This makes the increment happen on the FIRST press.
		vim.api.nvim_feedkeys("\x01", "n", false)

		-- CASE 3: The word is neither a boolean nor a number.
	else
		-- Do nothing. This empty block prevents the "freeze" on normal words.
	end
end

-- Helper for open_root_todo()
local function find_todo_in_dir(dir)
	for filename in vim.fs.dir(dir) do
		local basename = filename:gsub("%..*$", "")
		if basename:lower() == "todo" then
			return vim.fs.joinpath(dir, filename)
		end
	end
	return nil
end

-- Open cwd root todo file
function M.open_root_todo()
	local markers = {
		".git",
		"Makefile",
		"package.json",
		"pyproject.toml",
		"Cargo.toml",
		"go.mod",
		"todo",
	}

	local root_dir = vim.fs.root(0, markers)

	if root_dir then
		local todo_file = find_todo_in_dir(root_dir)

		if todo_file then
			vim.cmd.edit(todo_file)
			print("Opened project todo: " .. todo_file)
		else
			local new_todo_path = vim.fs.joinpath(root_dir, "todo")
			vim.cmd.edit(new_todo_path)
			print("Created new project todo: " .. new_todo_path)
		end
	else
		local global_todo = vim.fs.normalize("~/.todo")
		vim.cmd.edit(global_todo)
		print("No project root found. Opened global todo: " .. global_todo)
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

function M.get_local_word_dict()
	local default_dict = vim.fs.normalize("~/personal/words.txt")
	local sources = { default_dict }
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

function M.insert_screenshot()
	local ftype = vim.bo.filetype

	if ftype ~= "typst" then
		return vim.notify(
			"ft is not typst, cannot find format for current ft",
			vim.log.levels.WARN
		)
	end

	local filePath = vim.fs.normalize("~/.typst/local/snips/0.1.0/snipmap.csv")
	local lastLine = vim.fn.system({ "awk", "END{print}", filePath })
	local snip = lastLine:gsub(",.*$", "")

	local templates = {
		typst = {
			'#snip("' .. snip .. '"),',
		},
	}

	local template_string = templates[ftype]

	local function insert_lines(template)
		for i, txt in ipairs(template) do
			local row, col = unpack(vim.api.nvim_win_get_cursor(0))
			vim.api.nvim_buf_set_lines(
				0,
				row + i - 2,
				row + i - 1,
				false,
				{ txt }
			)
		end
	end

	insert_lines(template_string)
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

-- Cache for snippet objects
local keymap_snippets_cache = nil

local function get_keymap_snippets()
	if keymap_snippets_cache then
		return keymap_snippets_cache
	end

	local ls = require("luasnip")
	local s = ls.snippet
	local i = ls.insert_node
	local fmta = require("luasnip.extras.fmt").fmta

	keymap_snippets_cache = {
		["{"] = s("keymap_{", fmta("<>\n}", { i(1) })),
		["["] = s("keymap_[", fmta("<>\n]", { i(1) })),
		["("] = s("keymap_(", fmta("<>\n)", { i(1) })),
	}
	return keymap_snippets_cache
end

function M.smart_enter()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	-- Helper to send a raw <CR>
	local function plain_enter()
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes("<CR>", true, false, true),
			"n",
			false
		)
	end

	-- 1. Boundary check (Start of line)
	if col == 0 then
		return plain_enter()
	end

	local line = vim.api.nvim_get_current_line()
	local char_before = line:sub(col, col)

	-- 2. Check if we are after an opening bracket
	local pairs = { ["{"] = "}", ["["] = "]", ["("] = ")" }
	local closing_char = pairs[char_before]

	if closing_char then
		-- 3. ENHANCEMENT: Look ahead for the closing bracket
		-- Get text after cursor
		local rest_of_line = line:sub(col + 1)
		-- Find first non-whitespace character
		local next_char = rest_of_line:match("^%s*(.)")

		-- If the next relevant char is the closing one, DO NOT expand.
		-- Just do a normal enter to avoid double brackets: {|} -> {\n}
		if next_char == closing_char then
			return plain_enter()
		end

		-- Otherwise, expand the snippet
		local snippets = get_keymap_snippets()
		local snippet_to_expand = snippets[char_before]

		if snippet_to_expand then
			plain_enter()
			require("luasnip").snip_expand(snippet_to_expand)
		else
			plain_enter()
		end
	else
		plain_enter()
	end
end

return M
