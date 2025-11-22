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
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)

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
	local markers = { ".git", "Makefile", "package.json", "pyproject.toml", "Cargo.toml", "go.mod", "todo" }

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

function M.surround_motion_with()
	-- This operator funcon will run AFTER the user provides a motion (e.g., 'iw').
	_G.__surround_operator_func = function()
		-- 1. Get the character for the surrounding pair.
		vim.api.nvim_echo({ { "", "Question" } }, true, {})
		local char_code = vim.fn.getchar()

		if char_code == 27 or char_code == 3 then -- Allow canceling with Escape or Ctrl-C
			vim.api.nvim_echo({}, false, {}) -- Clear the prompt
			return
		end
		local user_input_char = vim.fn.nr2char(char_code)
		vim.api.nvim_echo({}, false, {}) -- Clear the prompt

		-- 2. Handle aliases (b, B, m) and determine the delimiter pair.
		local aliases = { b = "(", B = "{", m = "'" }
		local open_char = aliases[user_input_char] or user_input_char

		local closing_pairs = { ["("] = ")", ["["] = "]", ["{"] = "}" }
		local close_char = closing_pairs[open_char] or open_char

		-- 3. Get the text covered by the motion using the '[ and '] marks.
		local start_pos = vim.api.nvim_buf_get_mark(0, "[")
		local end_pos = vim.api.nvim_buf_get_mark(0, "]")
		local start_line, start_col = start_pos[1] - 1, start_pos[2]
		local end_line, end_col = end_pos[1] - 1, end_pos[2] + 1

		local text_to_surround = vim.api.nvim_buf_get_text(0, start_line, start_col, end_line, end_col, {})

		-- 4. Construct the new text by adding the surrounding pair.
		text_to_surround[1] = open_char .. text_to_surround[1]
		text_to_surround[#text_to_surround] = text_to_surround[#text_to_surround] .. close_char

		-- 5. Replace the original text with the new, surrounded text.
		vim.api.nvim_buf_set_text(0, start_line, start_col, end_line, end_col, text_to_surround)
	end

	vim.o.operatorfunc = "v:lua._G.__surround_operator_func"
	return "g@"
end

function M.insert_screenshot()
	local ftype = vim.bo.filetype

	if ftype ~= "typst" then
		return vim.notify("ft is not typst, cannot find format for current ft", vim.log.levels.WARN)
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
			vim.api.nvim_buf_set_lines(0, row + i - 2, row + i - 1, false, { txt })
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

return M
