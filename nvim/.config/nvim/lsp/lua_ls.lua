local caps = require("lspcaps").caps

return {
	capabilities = caps,
	settings = {
		Lua = {
			telemetry = {
				enable = false,
			},
		},
	},
}
