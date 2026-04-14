local caps = require("ajf.lspcaps").caps

return {
	capabilities = caps,
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
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			ignoreDir = {
				".git",
				".cache",
				".vscode",
				"node_modules",
				-- "lazy",
			},
		},
	},
}
