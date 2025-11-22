local utils = require("ajf.utils")
local PLUGIN_NAME = "Copilot"

-- load function
local function do_load()
	vim.pack.add({
		{ src = "https://github.com/zbirenbaum/copilot.lua.git" },
	})
	require("copilot").setup({
		suggestion = {
			enabled = true,
			auto_trigger = true,
			hide_during_completion = true,
			debounce = 75,
			trigger_on_accept = true,
			keymap = {
				accept = "<M-l>",
				accept_word = false,
				accept_line = "<C-A>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
		},
	})
end

-- enable/disable functions for the toggle
local function do_enable()
	require("copilot").enable()
end

local function do_disable()
	require("copilot").disable()
end

-- persistent, gated triggers
utils.gated_on_event(PLUGIN_NAME, "InsertEnter", do_load)
utils.gated_on_command(PLUGIN_NAME, "Copilot", do_load)

-- toggle command
utils.create_gated_toggle(PLUGIN_NAME, do_enable, do_disable)
