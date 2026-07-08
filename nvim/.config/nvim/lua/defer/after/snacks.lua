local function load_and_remap_picker()
	local Snacks = require("snacks")

	Snacks.setup({
		image = { enabled = false },
		scratch = {
			enabled = true,
			ft = "markdown",
			icon = nil,
			win = {
				position = "right",
				height = 0.4,
				width = 0.4,
			},
		},
		picker = {
			enabled = true,
			auto_close = false,
			prompt = "> ",
			icons = {
				files = { enabled = false },
			},
			win = {
				input = {
					keys = {
						["<C-.>"] = { "toggle_hidden", mode = { "i" } },

						["."] = { "toggle_hidden", mode = { "n" } },
					},
				},
			},
			---@class snacks.picker.format
			format = function(item, _)
				return {
					{ item.pos, item.text_hl },
				}
			end,
			formatters = { file = { icon_width = 0 } },
			sources = {
				files = {
					hidden = true,
				},
			},
		},
	})

	local main_layout = {

		layout = {
			layout = {
				backdrop = false,
				row = 0,
				height = function()
					return vim.o.lines - 2
				end,
				box = "horizontal",

				{

					title_pos = "left",
					box = "vertical",
					border = false,
					{ win = "input", height = 1, border = "none" },
					{ win = "list", border = "none" },
				},
				{
					win = "preview",
					border = false,
					width = 0.5,
				},
			},
		},
	}

	local bellow_layout = {
		layout = {
			layout = {
				position = "bottom",
				box = "horizontal",
				border = false,
				width = 1,
				height = 0.3,
				{
					box = "vertical",
					border = false,
					title_pos = "left",
					{ win = "input", height = 1, border = "none" },
					{ win = "list", border = "none" },
				},
			},
		},
	}
	local _picker_map = {
		{ "<leader>ff", Snacks.picker.files, "Picker: Files" },
		{ "<leader>fn", Snacks.picker.notifications, "Picker: Notifications" },
		{
			"<leader>ft",
			require("skeletal.integrations.snacks").picker,
			"Picker: Files",
			{ all = true },
		},
		{ "<leader>fb", Snacks.picker.buffers, "Picker: Buffers", bellow_layout },
		{ "<leader>fr", Snacks.picker.recent, "Picker: Recent" },
		{ "<leader>fg", Snacks.picker.git_files, "Picker: Git Files" },
		{ "<leader>gb", Snacks.picker.git_branches, "Picker: Git Branches" },
		{ "<leader>gs", Snacks.picker.git_status, "Picker: Git Status" },
		{ "<leader>gl", Snacks.picker.git_log, "Picker: Git Log" },
		{ "<leader>gd", Snacks.picker.git_diff, "Picker: Git Diff (Hunks)" },
		{ "<leader>gL", Snacks.picker.git_log_file, "Picker: Git Log File" },
		{ "<leader>sk", Snacks.picker.keymaps, "Picker: Keymaps" },
		{ "<leader>sm", Snacks.picker.man, "Picker: Man Pages" },
		{ "<leader>sh", Snacks.picker.help, "Picker: Help Pages" },
		{ "<leader>su", Snacks.picker.undo, "Picker: Unbo History" },
		{ "<leader>sc", Snacks.picker.commands, "Picker: Commands" },
		{ "<leader>s/", Snacks.picker.search_history, "Picker: Search History" },
		{ "<leader>sv", Snacks.picker.cliphist, "Picker: Clipboard History" },
		{ "<leader>sP", Snacks.picker.pickers, "Picker: All Pickers " },
		{ "<leader>sT", Snacks.picker.treesitter, "Picker: Treesitter" },

		{ "<leader>rg", Snacks.picker.grep, "Picker: Grep" },
		{ "<leader>rw", Snacks.picker.grep_word, "Picker: Grep cword" },

		{ "<leader>gs", Snacks.picker.lsp_symbols, "Picker: Inspect Lsp symbols" },
		{
			"<leader>gS",
			Snacks.picker.lsp_workspace_symbols,
			"Picker: Inspect Workspace symbols",
		},

		{ "<leader>ss", Snacks.picker.scratch, "Select Scratch Buffer" },
	}

	local global_note = {
		name = "Global",
		ft = "markdown",
		icon = "G",
		filekey = {
			id = "2nxazdzdp340rjjjch6i06vhl",
			cwd = false,
			branch = false,
			count = false,
		},
	}

	local _scratch_map = {
		{ "<leader>N", Snacks.scratch.open, "Toggle Scratch Buffer", global_note },
		{ "<leader>n", Snacks.scratch.open, "Toggle Scratch Buffer", {} },
	}

	local function map_keymap(keymap, def_opts)
		for _, k in ipairs(keymap) do
			k[4] = k[4] or def_opts
			local callback = k[4] and function()
				k[2](k[4])
			end
			vim.keymap.set("n", k[1], callback, { desc = k[3] })
		end
	end
	map_keymap(_picker_map, main_layout)

	map_keymap(_scratch_map)

	-- Deactivate full line highlight for selected line, and highlight only the selected text.
	local ns_cursor = vim.api.nvim_create_namespace("snacks_picker_custom_cursor")
	local ns_list = vim.api.nvim_create_namespace("snacks.picker.list")
	local List = require("snacks.picker.core.list")

	-- Make sure SnacksPickerPrompt is not bold (must copy attributes since link ignores overrides)
	local function update_prompt_hl()
		local special_hl =
			vim.api.nvim_get_hl(0, { name = "Special", link = false })
		local prompt_hl =
			vim.tbl_extend("force", special_hl, { bold = false, nocombine = true })
		vim.api.nvim_set_hl(0, "SnacksPickerPrompt", prompt_hl)
	end
	update_prompt_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = update_prompt_hl,
	})

	function List:update_cursorline()
		if
			not self.win:win_valid() or not vim.api.nvim_buf_is_valid(self.win.buf)
		then
			return
		end

		-- Disable built-in cursorline highlight
		Snacks.util.wo(self.win.win, {
			cursorline = false,
		})

		-- Clear existing custom cursor highlight
		vim.api.nvim_buf_clear_namespace(self.win.buf, ns_cursor, 0, -1)

		if self:count() == 0 then
			return
		end

		-- Highlight the current line's text only (excluding leading and trailing spaces)
		local row = self:idx2row(self.cursor)
		local line_text =
			vim.api.nvim_buf_get_lines(self.win.buf, row - 1, row, false)[1]

		local start_col = 0
		local end_col = 0
		if line_text and #line_text > 0 then
			local first_non_space = string.find(line_text, "%S")
			if first_non_space then
				start_col = first_non_space - 1
			end
			local last_non_space = string.find(line_text, "%S%s*$")
			if last_non_space then
				end_col = last_non_space
			end
		end

		if end_col > start_col then
			local hl_group = self.picker:is_focused()
					and "SnacksPickerListCursorLine"
				or "CursorLine"
			vim.api.nvim_buf_set_extmark(
				self.win.buf,
				ns_cursor,
				row - 1,
				start_col,
				{
					end_col = end_col,
					hl_group = hl_group,
					priority = 10, -- lower priority than search highlights (100)
				}
			)
		end

		if line_text and #line_text > 0 then
			-- Place the prompt at column 0
			local prompt = vim.trim(self.picker.opts.prompt or ">")
			vim.api.nvim_buf_set_extmark(self.win.buf, ns_cursor, row - 1, 0, {
				virt_text = { { prompt, "SnacksPickerPrompt" } },
				virt_text_pos = "overlay",
				priority = 100, -- high priority to ensure prompt shows over background
			})
		end
	end

	function List:_render(item, row)
		local text, extmarks = self:format(item)
		text = " " .. text:gsub("\n", " ")
		vim.api.nvim_buf_set_lines(self.win.buf, row - 1, row, false, { text })
		for _, extmark in ipairs(extmarks) do
			local col = extmark.col
			if col then
				col = col + 1
			end
			if extmark.end_col then
				extmark.end_col = extmark.end_col + 1
			end
			extmark.col = nil
			extmark.row = nil
			extmark.field = nil
			local ok, err = pcall(
				vim.api.nvim_buf_set_extmark,
				self.win.buf,
				ns_list,
				row - 1,
				col,
				extmark
			)
			if not ok and self.picker.opts.debug.extmarks then
				Snacks.notify.error(
					"Failed to set extmark.\n"
						.. err
						.. "\n```lua\n"
						.. vim.inspect(extmark)
						.. "\n```"
				)
			end
		end
	end
end

return {
	name = "snacks",
	src = "https://github.com/folke/snacks.nvim.git",
	load = load_and_remap_picker,
	libs = { "plenary", "devicons" },
}
