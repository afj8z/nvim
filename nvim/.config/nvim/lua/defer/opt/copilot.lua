local controller_load_fn = require("defer").create_toggle_controller("Copilot", {
	load = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = {
				auto_refresh = true,
			},
		})
	end,

	-- How to Enable
	enable = function()
		vim.cmd("Copilot enable")
	end,

	-- How to Disable
	disable = function()
		vim.cmd("Copilot disable")
	end,
})

return {
	name = "copilot",
	src = "https://github.com/zbirenbaum/copilot.lua.git",
	load = controller_load_fn,
	cmds = { "Copilot" },
}
