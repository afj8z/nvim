local function load_and_remap_picker()
	local clr = require("ajf.colors")
	local Snacks = require("snacks")
	local buffer_otps = {
		layout = {
			preview = "main",

			layout = {
				box = "vertical",
				backdrop = false,
				row = -2,
				width = 0,
				height = function()
					return vim.o.lines / 4
				end,
				border = "top",
				title = " {title} {live} {flags}",
				title_pos = "left",
				{ win = "input", height = 1, border = "none" },
				{
					box = "horizontal",
					{ win = "list", border = "none" },
					{
						win = "preview",
						title = "{preview}",
						width = 0.6,
						border = "left",
					},
				},
			},
		},
	}
	local _keymap = {
		{ "<leader>ff", Snacks.picker.files, "Picker: Files" },
		{ "<leader>fn", Snacks.picker.notifications, "Picker: Notifications" },
		{ "<leader>fb", Snacks.picker.buffers, "Picker: Buffers", buffer_otps },
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
		{ "<leader>su", Snacks.picker.undo, "Picker: Undo History" },
		{ "<leader>sc", Snacks.picker.commands, "Picker: Commands" },
		{ "<leader>s/", Snacks.picker.search_history, "Picker: Search History" },
		{ "<leader>sv", Snacks.picker.cliphist, "Picker: Clipboard History" },
		{ "<leader>sP", Snacks.picker.pickers, "Picker: Clipboard History" },
		{ "<leader>sT", Snacks.picker.treesitter, "Picker: Clipboard History" },
		-- { "<leader>se", Snacks.picker.explorer, "Picker: Clipboard History" },

		{ "<leader>rg", Snacks.picker.grep, "Picker: Grep" },
		{ "<leader>rw", Snacks.picker.grep_word, "Picker: Grep cword" },

		{ "<leader>gs", Snacks.picker.lsp_symbols, "Picker: Grep cword" },
		{ "<leader>gS", Snacks.picker.lsp_workspace_symbols, "Picker: Grep cword" },
	}

	for _, k in ipairs(_keymap) do
		local callback = k[4] and function()
			k[2](k[4])
		end or k[2]
		vim.keymap.set("n", k[1], callback, { desc = k[3] })
	end

	Snacks.setup({
		picker = {
			enabled = true,

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
		},
	})

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
	name = "picker",
	src = "https://github.com/folke/snacks.nvim.git",
	load = load_and_remap_picker,
	libs = { "plenary", "devicons" },
}
