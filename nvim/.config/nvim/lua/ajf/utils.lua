local M = {}

-- Registry for custom settings
local settings_cache = {}

--- Stores the main configuration table.
---@param settings table The settings table to store.
function M.set_settings(settings)
	settings_cache = settings
end

--- Retrieves the stored configuration table.
-- @return table The settings table.
function M.get_settings()
	return settings_cache
end

function M.nmap(lhs, rhs, opt)
	vim.keymap.set("n", lhs, rhs, opt)
end

function M.imap(lhs, rhs, opt)
	vim.keymap.set("i", lhs, rhs, opt)
end

function M.vmap(lhs, rhs, opt)
	vim.keymap.set("v", lhs, rhs, opt)
end

function M.tmap(lhs, rhs, opt)
	vim.keymap.set("t", lhs, rhs, opt)
end
---@param hl_map table Key: Highlight group. Value: Highlight options.
function M.set_highlights(hl_map)
	return function()
		for hl_group, color_opts in pairs(hl_map) do
			vim.api.nvim_set_hl(0, hl_group, color_opts)
		end
	end
end

return M
