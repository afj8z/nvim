local function load_and_remap_picker()
	local clr = require("ajf.colors")
	local Snacks = require("snacks")

	local fixed_bottom = {
		layout = {
			layout = { position = "bottom", height = 0.4, width = 0.4 },
		},
	}
	local main_layout = {
		layout = {
			layout = {
				row = 0,
				height = function()
					return vim.o.lines - 2
				end,
				box = "horizontal",

				{

					title_pos = "left",
					box = "vertical",
					border = true,
					title = "{title} {live} {flags}",
					{ win = "input", height = 1, border = "none" },
					{ win = "list", border = "none" },
				},
				{
					win = "preview",
					title = "{preview}",
					border = true,
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
				width = 1,
				height = 0.3,
				{
					box = "vertical",
					border = true,
					title = "{title} {live} {flags}",
					title_pos = "left",
					{ win = "input", height = 1 },
					{ win = "list", border = "none" },
				},
				{
					win = "preview",
					border = true,
					width = 0.5,
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
		{ "<leader>fr", Snacks.picker.recent, "Picker: Recent", fixed_bottom },
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

			sources = {
				files = {
					hidden = true,
				},
				select = {
					layout = {
						hidden = { "preview" },
						layout = {
							relative = "cursor",
							backdrop = false,
							width = 0.5,
							min_width = 80,
							max_width = 100,
							height = 0.4,
							min_height = 2,
							row = 1,
							box = "vertical",
							border = "top",
							title = "{title}",
							title_pos = "left",
							{ win = "input", height = 1 },
							{ win = "list" },
							{
								win = "preview",
								title = "{preview}",
								height = 0.4,
							},
						},
					},
				},
			},
		},
	})

	map_keymap(_scratch_map)

	vim.api.nvim_set_hl(0, "SnacksPicker", { link = "Normal", nocombine = true })
	vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = clr.bg, nocombine = true })
	vim.api.nvim_set_hl(0, "SnacksPickerPreview", { bg = clr.bg, nocombine = true })
	vim.api.nvim_set_hl(
		0,
		"SnacksPickerBorder",
		{ fg = clr.bg, bg = clr.bg, nocombine = true }
	)
end

return {
	name = "snacks",
	src = "https://github.com/folke/snacks.nvim.git",
	load = load_and_remap_picker,
	libs = { "plenary", "devicons" },
}
