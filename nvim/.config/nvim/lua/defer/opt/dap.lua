local function setup_dap()
	local dap = require("dap")
	local ui = require("dapui")

	require("dapui").setup()
	require("dap-go").setup()
end

---@type defer.PluginOpts
return {
	name = "dap",
	load = setup_dap,
	src = { "https://codeberg.org/mfussenegger/nvim-dap.git" },
	exts = { "https://github.com/leoluz/nvim-dap-go" },
	libs = { "nio", "dap-ui" },
	cmds = { "DapNew" },
}
