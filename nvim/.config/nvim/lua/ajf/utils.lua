local M = {}

local settings_cache = {}

--- Stores the main configuration table.
-- @param settings table The settings table to store.
function M.set_settings(settings)
	settings_cache = settings
end

--- Retrieves the stored configuration table.
-- @return table The settings table.
function M.get_settings()
	return settings_cache
end

--- Loads a specific list of modules from a given subdirectory.
-- @param subdir string The subdirectory within /lua
-- @param modules table A list of module names to load from that subdir.
function M.load_modules(subdir, modules)
	for _, module_name in ipairs(modules) do
		local full_module_path = subdir .. "." .. module_name

		-- pcall safely loads the code. If a file has an
		-- error, it won't crash Neovim.
		local ok, err = pcall(require, full_module_path)
		if not ok then
			vim.notify(
				"Error loading module: " .. full_module_path .. "\n" .. err,
				vim.log.levels.ERROR
			)
		end
	end
end

---Creates a self-cleaning autocommand to lazy-load a plugin on a
---specific filetype.
---@param plugin_name string: A unique name (e.g., "Colorize") for the augroup.
---@param patterns table: A list of filetype patterns (e.g., {"css", "html"}).
---@param load_callback function: The function to run, which should
---       call vim.pack.add(...) and require(...).setup().
function M.lazy_on_filetype(plugin_name, patterns, load_callback)
	local augroup_name = "LazyLoad" .. plugin_name
	local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = patterns,
		once = true,
		callback = function(args)
			vim.defer_fn(function()
				vim.notify(
					"Loading " .. plugin_name .. "...",
					vim.log.levels.INFO,
					{
						title = "Plugins",
					}
				)
			end, 0)

			load_callback(args)
		end,
	})
end

---Creates a "stub" keymap that loads a plugin on its first use.
---@param mode string|table: The keymap mode (e.g., "n", { "n", "v" })
---@param lhs string: The left-hand side of the keymap
---@param load_callback function: A function that loads the plugin AND
---       re-defines the keymap to its *real* function.
---@param opts table: Standard keymap options (e.g., { desc = "..." })
function M.keymap_stub(mode, lhs, load_callback, opts)
	opts = opts or {}
	opts.desc = (opts.desc or "lazy-stub") .. " (lazy)"

	vim.keymap.set(mode, lhs, function()
		vim.keymap.del(mode, lhs)
		load_callback()
		local keys = vim.api.nvim_replace_termcodes(lhs, true, false, true)
		vim.api.nvim_input(keys) -- Replay the keypress
	end, opts)
end

---Creates a "stub" command that loads a plugin on its first use.
---@param command_name string: The name of the User command (e.g., "FzfLua")
---@param load_callback function: A function that loads the plugin and
---       re-defines this command.
function M.command_stub(command_name, load_callback)
	vim.api.nvim_create_user_command(command_name, function(args)
		vim.api.nvim_del_user_command(command_name)
		load_callback()
		-- Re-run the command with original args
		vim.cmd(command_name .. " " .. (args.args or ""))
	end, {
		nargs = "*",
	})
end

-- [Keep all functions above M.command_stub] --

---Creates a controller to Lazy-Load and Toggle a plugin.
---It defines a command :{Name}Toggle automatically.
---@param name string: The display name of the plugin (e.g., "Copilot")
---@param opts table: Lifecycle functions
---    - load: function() -> Code to packadd/setup the plugin (runs once)
---    - enable: function() -> Code to enable the plugin (runs on toggle ON)
---    - disable: function() -> Code to disable the plugin (runs on toggle OFF)
---@return function: The 'load' function, so you can use it in other stubs.
function M.create_toggle_controller(name, opts)
	-- Internal state for this specific plugin
	local state = {
		loaded = false,
		enabled = false,
	}

	-- The core loading logic
	local function load_plugin()
		if state.loaded then
			return
		end
		-- 1. Run the user's load function (packadd + setup)
		opts.load()
		state.loaded = true
		state.enabled = true -- We assume setup() enables it by default
	end

	vim.api.nvim_create_user_command(name .. "Toggle", function()
		-- Not loaded yet? Load it.
		if not state.loaded then
			load_plugin()
			vim.notify(
				name .. " Loaded & Enabled",
				vim.log.levels.INFO,
				{ title = "Plugins" }
			)
			return
		end

		-- Already loaded? Toggle it.
		if state.enabled then
			if opts.disable then
				opts.disable()
			end
			state.enabled = false
			vim.notify(
				name .. " Disabled",
				vim.log.levels.WARN,
				{ title = "Plugins" }
			)
		else
			if opts.enable then
				opts.enable()
			end
			state.enabled = true
			vim.notify(
				name .. " Enabled",
				vim.log.levels.INFO,
				{ title = "Plugins" }
			)
		end
	end, { desc = "Lazy-Load / Toggle " .. name })

	-- Return the load function to attach it to other commands
	return load_plugin
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

---@param hl_map table Key: Highlight group. Value: Highlight options.
function M.set_highlights(hl_map)
	return function()
		for hl_group, color_opts in pairs(hl_map) do
			vim.api.nvim_set_hl(0, hl_group, color_opts)
		end
	end
end

function M.bind_map_pre_stub(map_func, mappings, options, pre_func)
	for keybind, target_func in pairs(mappings) do
		local operation = function()
			if pre_func then
				pre_func()
			end
			target_func(options)
		end
		map_func(keybind, operation)
	end
end

return M
