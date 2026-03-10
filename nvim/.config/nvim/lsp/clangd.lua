-- local caps = require("ajf.lspcaps").caps
return {
	-- capabilities = caps,
	cmd = { "clangd", "--clang-tidy", "--clang-tidy-checks=*" },
}
