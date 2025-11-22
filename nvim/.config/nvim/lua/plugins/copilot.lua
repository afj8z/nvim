local utils = require("ajf.utils")

local controller_load_fn = utils.create_toggle_controller("Copilot", {
	load = function()
		vim.pack.add({
			{ src = "https://github.com/zbirenbaum/copilot.lua.git" },
		})
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

-- :Copilot command will also trigger the load
utils.command_stub("Copilot", controller_load_fn)
