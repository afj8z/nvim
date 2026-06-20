local function load_codediff()
	require("codediff").setup({
		explorer = {
			position = "left",
			hidden = true,
		},
	})
end

---@type defer.PluginOpts
return {
	name = "codediff",
	load = load_codediff,
	src = { "https://github.com/esmuellert/codediff.nvim.git" },
	cmds = { "CodeDiff" },
	deps = { "treesitter" },
}
