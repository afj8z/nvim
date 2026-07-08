local caps = require("ajf.lspcaps").caps

-- filter to exclude current workspace name from runtime
local function get_filtered_runtime()
	local cwd_name = vim.fs.basename(vim.uv.cwd())
	local lib = {}

	for _, path in ipairs(vim.api.nvim_get_runtime_file("lua", true)) do
		if not path:match(cwd_name) then
			table.insert(lib, path)
		end
	end
	return lib
end

return {
	capabilities = caps,

	---@type lspconfig.settings.lua_ls
	settings = {
		Lua = {
			telemetry = {
				enable = false,
			},
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- library = get_filtered_runtime(),
				library = vim.api.nvim_get_runtime_file("lua", true),
				checkThirdParty = false,
				ignoreDir = {
					".git",
					".cache",
					".vscode",
					"node_modules",
					".tests",
					".github",
					"lazy",
				},
			},
		},
	},
}
