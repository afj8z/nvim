local caps = require("lspcaps").caps

return {
	root_markers = { ".git", "typst.toml", "typrc.typ" },
	root_dir = util.root_pattern(".git", "typst.toml", "typrc.typ") or util.find_git_ancestor,
	capabilities = caps,
	settings = {
		formatterMode = "typstyle",
		formatterIndentSize = 4,
		formatterPrintWidth = 80,
		formatterProseWrap = true,
		lint = {
			enabled = true,
		},
	},
}
