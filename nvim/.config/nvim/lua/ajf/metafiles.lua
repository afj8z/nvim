local M = {}

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

local meta_markers = {
	".gitignore",
	"Makefile",
	"package.json",
	"pyproject.toml",
	"Cargo.toml",
	"go.mod",
	"todo",
	"local-words",
	"README.md",
	".envrc",
	".project",
}

local function find_word_in_dir(dir)
	for filename in vim.fs.dir(dir) do
		local basename = filename:gsub("%..*$", "")
		if basename:lower() == "local-words" then
			return vim.fs.joinpath(dir, filename)
		end
	end
	return nil
end

local function get_local_word_dict()
	local default_files = vim.fs.normalize("~/personal/words.txt")
	local sources = { default_files }
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

-- local notes_dir = get_local_word_dict

local function dirLookup(dir, file_name, map)
	local p = io.popen('find "' .. dir .. '" -type f') --Open directory look for files, save data in p. By giving '-type f' as parameter, it returns all files.
	for file in p:lines() do --Loop through all files
		if file == dir .. "/" .. file_name then
			table.insert(map, file)
			-- print("found file " .. file .. "\n")
		end
	end
end

---@return tbl table
local function get_dirs(par, cur)
	-- root $EDITOR dir (or $HOME?)
	-- local par = "/home/aidanfleming"
	-- current $EDITOR file
	-- local cur = "/home/aidanfleming/documents/uni/2025S/game-theory/"
	local rootd = par or "/home/aidanfleming"
	local cdir = cur
	if cdir == nil then
		cdir = string(vim.api.nvim_buf_get_name(0))
	end
	local map_files = {}
	while rootd ~= cdir do
		for _, fname in ipairs(meta_markers) do
			dirLookup(cdir, fname, map_files)
		end
		local pattern1 = "^(.+)/"
		cdir = string.match(cdir, pattern1)
		print(cdir)
		if cdir == rootd then
			break
		end
	end

	return map_files
end

function M.toggle_notes()
	local cwf = vim.api.nvim_buf_get_name(0)
	local cdir = vim.fs.dirname(cwf)
	local rootd = "/home/aidanfleming"
	local notes = get_dirs(rootd, cdir)
	-- if vim.tbl_isempty(notes) then
	-- 	vim.notify("No notes found in " .. notes_dir, vim.log.levels.WARN)
	-- 	return
	-- end

	-- local note_files = {}
	-- for _, path in ipairs(notes) do
	-- 	table.insert(note_files, vim.fn.fnamemodify(path, ":t"))
	-- end

	vim.ui.select(notes, { prompt = "Select note:" }, function(choice)
		if not choice then
			return
		end

		local file_path = choice
		vim.cmd("edit " .. vim.fn.fnameescape(file_path))
	end)
end

return M
