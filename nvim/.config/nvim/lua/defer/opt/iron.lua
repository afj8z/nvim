local function load_and_remap_iron()
	local iron = require("iron.core")
	local view = require("iron.view")
	local common = require("iron.fts.common")

	iron.setup({
		config = {
			-- Whether a repl should be discarded or not
			scratch_repl = true,
			-- Your repl definitions come here
			repl_definition = {
				R = {
					-- Can be a table or a function that
					-- returns a table (see below)
					command = { "arf" },
					format = common.bracketed_paste,
				},
				r = {
					-- Can be a table or a function that
					-- returns a table (see below)
					command = { "arf" },
					format = common.bracketed_paste,
				},
				quarto = {
					command = { "arf" },
					format = common.bracketed_paste,
				},
			},
			-- set the file type of the newly created repl to ft
			-- bufnr is the buffer id of the REPL and ft is the filetype of the
			-- language being used for the REPL.
			repl_filetype = function(bufnr, ft)
				return "iron"
				-- or return a string name such as the following
				-- return "iron"
			end,
			-- Send selections to the DAP repl if an nvim-dap session is running.
			dap_integration = true,
			-- How the repl window will be displayed
			-- See below for more information
			repl_open_cmd = require("iron.view").split.vertical.botright("40%"),

			-- repl_open_cmd can also be an array-style table so that multiple
			-- repl_open_commands can be given.
			-- When repl_open_cmd is given as a table, the first command given will
			-- be the command that `IronRepl` initially toggles.
			-- Moreover, when repl_open_cmd is a table, each key will automatically
			-- be available as a keymap (see `keymaps` below) with the names
			-- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
			-- For example,
			--
			-- repl_open_cmd = {
			--   view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
			--   view.split.rightbelow("%25")  -- cmd_2: open a repl below
			-- }
		},
		-- Iron doesn't set keymaps by default anymore.
		-- You can set them here or manually add keymaps to the functions in iron.core
		keymaps = {
			-- send_motion = "<localleader>R",
			visual_send = "<localleader>rv",
			send_file = "<localleader>rf",
			send_line = "<localleader>rl",
			-- send_paragraph = "<localleader>rp",
			send_until_cursor = "<localleader>ru",
			send_mark = "<localleader>rm",
			-- mark_motion = "<localleader>mc",
			mark_visual = "<localleader>ra",
			remove_mark = "<localleader>rd",
			cr = "<localleader>r<cr>",
			interrupt = "<localleader>rs",
			exit = "<localleader>rq",
			clear = "<localleader>rc",
		},
		-- If the highlight is on, you can change how it looks
		-- For the available options, check nvim_set_hl
		highlight = {
			italic = true,
		},
		ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
	})

	vim.keymap.set(
		"n",
		"<localleader>R",
		"<cmd>IronRepl<cr>",
		{ desc = "[R]EPL [S]tart" }
	)
	vim.keymap.set(
		"n",
		"<localleader>rR",
		"<cmd>IronRestart<cr>",
		{ desc = "[R]EPL [R]estart" }
	)
	vim.keymap.set("n", "<space>rj", "<cmd>IronFocus<cr>")
	vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
end

return {
	name = "iron",
	src = "https://github.com/Vigemus/iron.nvim.git",
	load = load_and_remap_iron,
	keys = {
		{ "n", "<leader>R", desc = "Start Repl" },
	},
	cmds = {
		"IronRepl",
	},
}
