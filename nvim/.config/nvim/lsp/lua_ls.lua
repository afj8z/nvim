local caps = require("ajf.lspcaps").caps

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
