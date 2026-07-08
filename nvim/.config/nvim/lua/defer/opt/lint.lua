local function load_lint()
	local lint = require("lint")

	lint.linters_by_ft = {
		c = { "cppcheck" },
		cpp = { "cppcheck" },
		-- go = { "golangci-lint" },
	}

	local cppcheck = lint.linters.cppcheck
	cppcheck.args = {
		"--enable=all",
		-- "--disable=missingInclude",
		function()
			if vim.bo.filetype == "cpp" then
				return "--language=c++"
			else
				return "--language=c"
			end
		end,
		"--template={file}:{line}:{column}: [{id}] {severity}: {message}",
		"--inline-suppr",
		"--suppress=missingInclude",
		"--check-level=exhaustive",
	}
	-- vim.keymap.set("n", "<leader>lc", function()
	-- 	lint.try_lint()
	-- 	vim.notify("Executed cppcheck", vim.log.levels.INFO)
	-- end, { desc = "Trigger nvim-lint (cppcheck)" })
end

return {
	name = "lint",
	src = "https://github.com/mfussenegger/nvim-lint.git",
	ft = {
		"c",
		"cpp",
		"go",
	},
	load = load_lint,
}
