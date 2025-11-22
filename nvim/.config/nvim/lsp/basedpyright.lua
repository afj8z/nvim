local caps = require("ajf.lspcaps").caps

return {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
	capabilities = caps,
	settings = {
		basedpyright = {
			disableOrganizeImports = true, -- let Ruff handle imports
			-- analysis = { typeCheckingMode = "basic" }, -- optional
		},
	},
}
