local function setup_dap()
	local dap = require("dap")
	local ui = require("dapui")

	dap.set_log_level("TRACE")
	ui.setup()

	-- ui.setup({
	-- 	layouts = {
	-- 		{
	-- 			elements = {
	-- 				{
	-- 					id = "scopes",
	-- 					size = 0.35,
	-- 				},
	-- 				{
	-- 					id = "breakpoints",
	-- 					size = 0.30,
	-- 				},
	-- 				{
	-- 					id = "repl",
	-- 					size = 0.35,
	-- 				},
	-- 			},
	-- 			position = "right",
	-- 			size = 50,
	-- 		},
	-- 	},
	-- })
	require("dap-go").setup({
		delve = {
			build_flags = "-ldflags=-X walkie/internal.DevMode=true",
		},
	})

	-- Custom configurations for debugging the walkie TUI
	dap.configurations.go = dap.configurations.go or {}
	table.insert(dap.configurations.go, {
		type = "go",
		name = "Debug TUI (External Terminal)",
		request = "launch",
		mode = "exec",
		program = "${workspaceFolder}/bin/walkie",
		cwd = "${workspaceFolder}",
		console = "externalTerminal",
		terminal_type = "external",
		args = { "tui" },
	})
	table.insert(dap.configurations.go, {
		type = "go",
		name = "Debug TUI (Tmux Split)",
		request = "launch",
		mode = "exec",
		program = "${workspaceFolder}/bin/walkie",
		cwd = "${workspaceFolder}",
		console = "externalTerminal",
		terminal_type = "tmux",
		args = { "tui" },
	})

	-- Intercept Go adapter to dynamically launch Delve inside tmux or kitty
	local original_go_adapter = dap.adapters.go
	dap.adapters.go = function(callback, config)
		if config.terminal_type then
			local cwd = config.cwd or vim.fn.getcwd()

			-- Automatically compile dev binary first
			vim.fn.system("make -C " .. cwd .. " dev")

			local port = 38697
			local cmd = ""
			local dlv_cmd = string.format("dlv dap --headless --listen=127.0.0.1:%d", port)

			if config.terminal_type == "tmux" then
				-- Spawn Delve in a new horizontal tmux split
				cmd = string.format("tmux split-window -c '%s' -h '%s'", cwd, dlv_cmd)
			else
				-- Spawn Delve in a new kitty terminal window
				cmd = string.format("kitty --directory '%s' -- %s", cwd, dlv_cmd)
			end

			-- Prevent Delve from trying to spawn another terminal
			config.console = nil

			-- Start Delve inside the target terminal session
			vim.fn.jobstart(cmd, { cwd = cwd })

			-- Give the Delve server a brief moment to bind to the port before Neovim connects
			vim.defer_fn(function()
				callback({
					type = "server",
					host = "127.0.0.1",
					port = port,
				})
			end, 500)
		else
			if type(original_go_adapter) == "function" then
				original_go_adapter(callback, config)
			else
				callback(original_go_adapter)
			end
		end
	end

	-- Keymaps
	local nmap = require("ajf.utils").nmap
	nmap("<F5>", dap.continue, { desc = "Debug: Start/Continue" })
	nmap("<F10>", dap.step_over, { desc = "Debug: Step Over" })
	nmap("<F11>", dap.step_into, { desc = "Debug: Step Into" })
	nmap("<F12>", dap.step_out, { desc = "Debug: Step Out" })
	nmap("<leader>bp", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
	nmap("<leader>B", function()
		dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, { desc = "Debug: Breakpoint Condition" })
	nmap("<leader>bu", ui.toggle, { desc = "Debug: Toggle UI" })
	nmap("<leader>bf", require("dap-go").debug_test, { desc = "Debug: Test (Go)" })
	nmap(
		"<leader>bl",
		require("dap-go").debug_last_test,
		{ desc = "Debug: Last (Go)" }
	)

	-- Visual indicators
	local ok, style = pcall(require, "ajf.style")
	local bug_icon = ok and style.icons.misc.bug or "●"

	vim.api.nvim_set_hl(0, "DapBreakpoint", { link = "DiagnosticError" })
	vim.api.nvim_set_hl(0, "DapBreakpointCondition", { link = "DiagnosticWarn" })
	vim.api.nvim_set_hl(0, "DapLogPoint", { link = "DiagnosticInfo" })
	vim.api.nvim_set_hl(0, "DapStopped", { link = "DiagnosticHint" })

	vim.fn.sign_define(
		"DapBreakpoint",
		{ text = bug_icon, texthl = "DapBreakpoint", linehl = "", numhl = "" }
	)
	vim.fn.sign_define(
		"DapBreakpointCondition",
		{ text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
	)
	vim.fn.sign_define(
		"DapLogPoint",
		{ text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" }
	)
	vim.fn.sign_define("DapStopped", {
		text = "▶",
		texthl = "DapStopped",
		linehl = "DapStopped",
		numhl = "DapStopped",
	})

	dap.listeners.before.attach.dapui_config = function()
		ui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		ui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		ui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		ui.close()
	end
end

---@type defer.PluginOpts
return {
	name = "dap",
	load = setup_dap,
	src = { "https://codeberg.org/mfussenegger/nvim-dap.git" },
	exts = { "https://github.com/leoluz/nvim-dap-go" },
	libs = { "nio", "dap-ui" },
	cmds = { "DapNew" },
	keys = {
		{ "n", "<F5>", desc = "Debug: Start/Continue" },
		{ "n", "<F10>", desc = "Debug: Step Over" },
		{ "n", "<F11>", desc = "Debug: Step Into" },
		{ "n", "<F12>", desc = "Debug: Step Out" },
		{ "n", "<leader>bp", desc = "Debug: Toggle Breakpoint" },
		{ "n", "<leader>B", desc = "Debug: Breakpoint Condition" },
		{ "n", "<leader>bu", desc = "Debug: Toggle UI" },
		{ "n", "<leader>bf", desc = "Debug: Test (Go)" },
		{ "n", "<leader>bl", desc = "Debug: Last (Go)" },
	},
}
