local M = {}

local function process_selection(callback)
	local reg_save = vim.fn.getreginfo("a")

	vim.cmd('noautocmd normal! "ay')
	local text = vim.trim(vim.fn.getreg("a"))

	if text and text ~= "" then
		local replacement, extra_action = callback(text)

		if replacement then
			vim.fn.setreg("a", replacement, "v")
			vim.cmd('noautocmd normal! gv"ap')
		end

		if extra_action then
			extra_action()
		end
	end

	vim.fn.setreg("a", reg_save)
end

function M.link_and_open(opts)
	process_selection(function(text)
		local filename = text:gsub("\n", ""):gsub("%s+", "-"):gsub("/", "-")
			.. "."
			.. opts.ext
		local link = opts.format(text, filename)

		local extra_action = function()
			local dir = vim.fn.expand("%:p:h")
			local new_filepath = dir .. "/" .. filename
			vim.cmd("edit " .. vim.fn.fnameescape(new_filepath))
		end

		return link, extra_action
	end)
end

function M.domain_link(opts)
	process_selection(function(url)
		local domain = url:match("^https?://([^/]+)")
		if not domain then
			vim.notify("Not a valid HTTP/HTTPS URL", vim.log.levels.WARN)
			return nil
		end

		domain = domain:gsub("^www%.", "")
		return opts.format(domain, url)
	end)
end

-- Evaluates the current line against a syntax pattern and extracts the target URL
-- if the cursor is currently positioned inside the pattern's start/end indices.
function M.get_link_under_cursor(pattern)
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	local start_idx = 1

	while true do
		local s, e, target = string.find(line, pattern, start_idx)
		if not s then
			break
		end

		if col >= s and col <= e then
			return target
		end
		start_idx = e + 1
	end
	return nil
end

function M.smart_gf(opts)
	local target = M.get_link_under_cursor(opts.pattern)

	if target then
		if target:match("^https?://") then
			vim.fn.jobstart({ "xdg-open", target }, { detach = true })
		else
			local dir = vim.fn.expand("%:p:h")
			local filepath = target:match("^/") and target or (dir .. "/" .. target)
			vim.cmd("edit " .. vim.fn.fnameescape(filepath))
		end
	else
		vim.cmd("normal! gf")
	end
end

return M
