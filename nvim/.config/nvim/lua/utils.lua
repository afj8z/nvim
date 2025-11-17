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
			vim.notify("Error loading module: " .. full_module_path .. "\n" .. err, vim.log.levels.ERROR)
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
	-- Create a unique, self-cleaning augroup for this specific load.
	local augroup_name = "LazyLoad" .. plugin_name
	local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = patterns,
		once = true, -- The autocmd deletes itself after firing once
		callback = function(args)
			vim.notify("Loading " .. plugin_name .. "...", vim.log.levels.INFO, {
				title = "Plugins",
			})
			-- Run the provided loader function
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

-- Central registry for state
-- M.gated_state["Copilot"] = { locked = true, loaded = false }
M.gated_state = {}

-- Initialize a plugin's state (default to locked)
local function init_gated_state(name)
	if not M.gated_state[name] then
		M.gated_state[name] = { locked = true, loaded = false }
	end
	return M.gated_state[name]
end

---@param name string: The plugin's unique name
---@param load_callback function: The function that runs vim.pack.add/setup
---@return boolean: true if load succeeded or already loaded
function M.attempt_gated_load(name, load_callback)
	local state = init_gated_state(name)

	if state.loaded then
		return true
	end
	if state.locked then
		return false
	end -- Locked, do not load

	-- Unlocked and not loaded
	state.loaded = true
	vim.notify("Loading " .. name .. "...", vim.log.levels.INFO, { title = "Plugins" })

	load_callback()

	-- Clean up triggers
	vim.api.nvim_clear_autocmds({ group = "GatedLoader_" .. name })
	return true
end

---Creates a persistent event trigger for a gated plugin
---@param name string: The plugin's unique name
---@param event string: The autocmd event (e.g., "InsertEnter")
---@param load_callback function: The function to run
function M.gated_on_event(name, event, load_callback)
	local augroup = vim.api.nvim_create_augroup("GatedLoader_" .. name, { clear = true })
	vim.api.nvim_create_autocmd(event, {
		group = augroup,
		callback = function()
			M.attempt_gated_load(name, load_callback)
		end,
	})
end

---Creates a persistent command trigger for a gated plugin
---@param name string: The plugin's unique name
---@param command_name string: The command to create ("Copilot")
---@param load_callback function: The function to run
function M.gated_on_command(name, command_name, load_callback)
	-- Ensure state exists on init
	init_gated_state(name)

	vim.api.nvim_create_user_command(command_name, function(args)
		if M.attempt_gated_load(name, load_callback) then
			-- delete stub and run the real command
			vim.api.nvim_del_user_command(command_name)
			vim.cmd(command_name .. " " .. (args.args or ""))
		end
		-- if locked, Stub remains
	end, { nargs = "*", desc = "Gated lazy-load stub for " .. name })
end

---Creates a toggle command for a "gated" plugin
---@param name string: The name used in create_gated_loader ("Copilot")
---@param enable_fn function?: Optional fn to run if already loaded and enabling
---@param disable_fn function?: Optional fn to run if already loaded and disabling
function M.create_gated_toggle(name, enable_fn, disable_fn)
	local state = init_gated_state(name)

	vim.api.nvim_create_user_command(name .. "Toggle", function()
		state.locked = not state.locked

		if state.locked then
			if state.loaded and disable_fn then
				disable_fn()
			end
			vim.notify(name .. " globally DISABLED.", vim.log.levels.WARN, { title = name })
		else
			if state.loaded and enable_fn then
				enable_fn()
			end
			vim.notify(name .. " globally ENABLED.", vim.log.levels.INFO, { title = name })
		end
	end, { desc = "Toggle " .. name .. " lazy-loading on/off" })
end

return M
