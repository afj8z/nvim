local caps = require("ajf.lspcaps").caps

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
