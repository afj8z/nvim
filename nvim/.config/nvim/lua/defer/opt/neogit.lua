-- local function load_neogit()
-- setup function
-- end

return {
	name = "neogit",
	src = "https://github.com/NeogitOrg/neogit.git",
	-- load = load_neogit,
	deps = { "telescope" },
	libs = "plenary",
	cmds = { "Neogit", "NeogitCommit" },
}
