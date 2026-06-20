vim.loader.enable()
local defer_path = vim.fn.expand("~/dev/defer.nvim")
if vim.fn.isdirectory(defer_path) == 1 then
	vim.opt.rtp:prepend(defer_path)
else
	vim.notify("defer.nvim not found at " .. defer_path, vim.log.levels.ERROR)
end
---@type defer.Module
Defer = require("defer")

-- shared style between plugins
local settings = {
	theme = "ever",
	border = "none",
	symbols = {
		error = "E",
		warn = "W",
		info = "I",
		hint = "H",
	},
}

-- bootstrap env
local node_bin_path = vim.fn.expand("$HOME/.config/nvm/versions/node/v24.12.0/bin")
if vim.fn.isdirectory(node_bin_path) == 1 then
	vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH
end

-- cache settings
require("ajf.utils").set_settings(settings)

require("config")

-- plugin manager setup
require("defer").pre_setup({
	width = { fill = true },
	init = vim.fn.stdpath("config") .. "/lua/defer/",
})
