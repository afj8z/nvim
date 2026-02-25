local utils = require("defer")

local controller_load_fn = utils.create_toggle_controller("Copilot", {

	load = function()
		-- node not in sys PATH, so make available to Mason in nvim
		local node_bin_path =
			vim.fn.expand("$HOME/.config/nvm/versions/node/v24.12.0/bin") -- Update version if needed
		if vim.fn.isdirectory(node_bin_path) == 1 then
			vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH
		end
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

return {
	name = "copilot",
	src = "https://github.com/zbirenbaum/copilot.lua.git",
	load = controller_load_fn,
	cmds = { "Copilot" },
}
