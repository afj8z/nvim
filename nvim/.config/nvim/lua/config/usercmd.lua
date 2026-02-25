local uf = require("ajf.userfunc")
local utils = require("defer")

vim.api.nvim_create_user_command("Spon", function()
	uf.toggle_spell_lang(true, "_")
end, {})

vim.api.nvim_create_user_command("Spoff", function()
	uf.toggle_spell_lang(false, "_")
end, {})

vim.api.nvim_create_user_command("Spde", function()
	uf.toggle_spell_lang(true, "de")
end, {})

vim.api.nvim_create_user_command("Spen", function()
	uf.toggle_spell_lang(true, "en")
end, {})

vim.api.nvim_create_user_command("SnipList", uf.list_snips, {})

vim.api.nvim_create_user_command("Spen", function()
	uf.toggle_spell_lang(true, "en")
end, {})

local function lua_runner()
	local cwd = vim.fn.getcwd(0)
	local fpath = vim.api.nvim_buf_get_name(0)
	local ft = vim.bo.filetype

	local fwd = vim.fn.fnamemodify(fpath, ":p:h")
	print(cwd, fpath, ft, fwd)
end

vim.api.nvim_create_user_command("LUA", function()
	lua_runner()
end, {})

--- Reusable wrapper to display a registry
---@param type_name string "plugins" or "libs"
---@param title string Display title
local function show_registry(type_name, title)
	local registry = type_name == "libs" and utils.get_libs() or utils.get_plugins()
	local lines = utils.format_registry_status(registry)

	table.insert(lines, 1, title)
	table.insert(lines, 2, string.rep("─", #title))

	vim.notify(
		table.concat(lines, "\n"),
		vim.log.levels.INFO,
		{ title = "Lazy Engine" }
	)
end

vim.api.nvim_create_user_command("LazyPlugins", function()
	show_registry("plugins", "Registered Plugins")
end, { desc = "List all registered plugins and their load status" })

vim.api.nvim_create_user_command("LazyLibs", function()
	show_registry("libs", "Registered Libraries")
end, { desc = "List all registered libraries and their load status" })

vim.api.nvim_create_user_command("LazyInfo", function(args)
	local name = args.args
	local data = utils.get_plugins()[name] or utils.get_libs()[name]

	if not data then
		return vim.notify("Module '" .. name .. "' not found.", vim.log.levels.WARN)
	end

	vim.notify(
		vim.inspect(data),
		vim.log.levels.INFO,
		{ title = "Lazy Info: " .. name }
	)
end, {
	nargs = 1,
	desc = "Inspect configuration and state of a registered plugin or lib",
	complete = function()
		-- Dynamically aggregate all registered names for tab-completion
		local keys = {}
		for k in pairs(utils.get_plugins()) do
			table.insert(keys, k)
		end
		for k in pairs(utils.get_libs()) do
			table.insert(keys, k)
		end
		table.sort(keys)
		return keys
	end,
})
