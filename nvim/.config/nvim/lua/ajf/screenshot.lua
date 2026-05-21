local uv = vim.uv or vim.loop

local M = {}

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "screenshots" })
end

local function path_join(...)
	return table.concat({ ... }, "/")
end

local function is_dir(path)
	return vim.fn.isdirectory(path) == 1
end

local function ensure_dir(path)
	if not is_dir(path) then
		vim.fn.mkdir(path, "p")
	end
	return path
end

local function exists(path)
	return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

local function current_buffer_dir()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return nil
	end
	return vim.fn.fnamemodify(file, ":p:h")
end

local function resolve_local_screenshot_dir(buf_dir, create_if_missing)
	local candidates = {
		path_join(buf_dir, "screenshots"),
		path_join(buf_dir, "screenshot"),
		path_join(buf_dir, "assets", "screenshots"),
		path_join(buf_dir, "asset", "screenshots"),
		path_join(buf_dir, "assets", "images"),
		path_join(buf_dir, "assets", "img"),
		path_join(buf_dir, "images"),
		path_join(buf_dir, "img"),
		path_join(buf_dir, "static", "images"),
		path_join(buf_dir, "public", "images"),
	}

	for _, candidate in ipairs(candidates) do
		if is_dir(candidate) then
			return candidate
		end
	end

	if not create_if_missing then
		return nil
	end

	if is_dir(path_join(buf_dir, "assets")) then
		return ensure_dir(path_join(buf_dir, "assets", "screenshots"))
	end
	if is_dir(path_join(buf_dir, "asset")) then
		return ensure_dir(path_join(buf_dir, "asset", "screenshots"))
	end
	return ensure_dir(path_join(buf_dir, "screenshots"))
end

local function global_screenshot_dir()
	return ensure_dir(path_join(vim.fn.stdpath("data"), "screenshots"))
end

local function screenshot_filename()
	return ("shot-%s-%03d.png"):format(
		os.date("%Y%m%d-%H%M%S"),
		math.floor((uv.hrtime() / 1e6) % 1000)
	)
end

local function run_capture(target_path)
	if vim.fn.executable("grim") ~= 1 or vim.fn.executable("slurp") ~= 1 then
		return false, "grim/slurp are required for screenshot capture."
	end

	local geometry = vim.trim(vim.fn.system({ "slurp" }))
	if vim.v.shell_error ~= 0 or geometry == "" then
		return false, "Screenshot cancelled."
	end

	vim.fn.system({ "grim", "-g", geometry, target_path })
	if vim.v.shell_error ~= 0 then
		return false, "grim failed to create screenshot."
	end
	if vim.fn.filereadable(target_path) ~= 1 then
		return false, "Screenshot file was not created."
	end
	return true
end

local function path_relative_to(base, target)
	local prefix = base .. "/"
	if target:sub(1, #prefix) == prefix then
		return target:sub(#prefix + 1)
	end
	return target
end

local function image_link_for_filetype(ft, rel_path)
	if ft == "tex" or ft == "plaintex" then
		return ("\\includegraphics{%s}"):format(rel_path)
	end
	if ft == "typst" then
		return ('#image("%s")'):format(rel_path)
	end
	if ft == "html" or ft == "xhtml" then
		return ('<img src="%s" alt="" />'):format(rel_path)
	end
	if ft == "org" then
		return ("[[file:%s]]"):format(rel_path)
	end
	if ft == "rst" then
		return (".. image:: %s"):format(rel_path)
	end
	if ft == "asciidoc" then
		return ("image::%s[]"):format(rel_path)
	end
	return ("![](%s)"):format(rel_path)
end

local function insert_at_cursor(text)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local updated = line:sub(1, col) .. text .. line:sub(col + 1)
	vim.api.nvim_set_current_line(updated)
	vim.api.nvim_win_set_cursor(0, { row, col + #text })
end

function M.capture_and_insert()
	local buf_dir = current_buffer_dir()
	if not buf_dir then
		notify(
			"Buffer has no file path. Save the file before inserting screenshots.",
			vim.log.levels.ERROR
		)
		return
	end

	local global_dir = global_screenshot_dir()
	local local_dir = resolve_local_screenshot_dir(buf_dir, true)
	local file = screenshot_filename()
	local global_path = path_join(global_dir, file)
	local local_link = path_join(local_dir, file)

	local ok, err = run_capture(global_path)
	if not ok then
		notify(err, vim.log.levels.ERROR)
		return
	end

	if exists(local_link) then
		vim.fn.delete(local_link)
	end
	local linked, link_err = uv.fs_symlink(global_path, local_link)
	if not linked then
		notify(
			("Failed to create symlink: %s"):format(link_err),
			vim.log.levels.ERROR
		)
		return
	end

	local rel_path = path_relative_to(buf_dir, local_link)
	local markup = image_link_for_filetype(vim.bo.filetype, rel_path)
	insert_at_cursor(markup)
end

local function open_screenshot_picker(dir, title)
	if not is_dir(dir) then
		notify(("Directory not found: %s"):format(dir), vim.log.levels.WARN)
		return
	end
	require("telescope").extensions.media_files.media_files({
		cwd = dir,
		prompt_title = title,
	})
end

function M.pick_local()
	local buf_dir = current_buffer_dir()
	if not buf_dir then
		notify("Buffer has no file path.", vim.log.levels.ERROR)
		return
	end
	local local_dir = resolve_local_screenshot_dir(buf_dir, false)
	if not local_dir then
		notify(
			"No local screenshot folder found for this buffer.",
			vim.log.levels.WARN
		)
		return
	end
	open_screenshot_picker(local_dir, "Local screenshots")
end

function M.pick_global()
	open_screenshot_picker(global_screenshot_dir(), "Global screenshots")
end

return M
