local caps = require("ajf.lspcaps").caps

return {
	root_markers = { ".git", "typst.toml", "typrc.typ" },
	capabilities = caps,
	settings = {
		formatterMode = "typstyle",
		formatterIndentSize = 4,
		formatterPrintWidth = 84,
		formatterProseWrap = true,
		lint = {
			enabled = true,
		},
	},
}
