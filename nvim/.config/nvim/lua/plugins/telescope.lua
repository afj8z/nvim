local utils = require("ajf.utils")
local c = require("ajf.style").colors
local nmap = utils.nmap
local bindmap = utils.bind_map_pre_stub

local reset_highlights = utils.set_highlights({
	TelescopePromptNormal = { bg = c.bg },
	TelescopePromptBorder = { bg = c.bg },
	TelescopePromptTitle = { fg = c.bg, bg = c.bg },
	TelescopePreviewTitle = { fg = c.bg, bg = c.bg },
	TelescopeResultsTitle = { fg = c.bg, bg = c.bg },
	TelescopeResultsNormal = { bg = c.bg },
	TelescopeResultsBorder = { bg = c.bg },
	TelescopePromptCounter = { fg = c.fg },
})

local set_cursor_highlights = utils.set_highlights({
	TelescopePromptNormal = { bg = c.float },
	TelescopePromptBorder = { bg = c.float },
	TelescopePromptTitle = { fg = c.float, bg = c.float },
	TelescopePreviewTitle = { fg = c.float, bg = c.float },
	TelescopeResultsTitle = { fg = c.float, bg = c.float },
	TelescopeResultsNormal = { bg = c.float },
	TelescopeResultsBorder = { bg = c.float },
	TelescopePromptCounter = { fg = c.fg },
})

local empty_border = { "" }
local top_border = { "━", "", "", "", "━", "━", "", "" }

local replicate_buffer = function()
	reset_highlights()
	vim.api.nvim_create_autocmd("User", {
		pattern = "TelescopePreviewerLoaded",
		once = true,
		callback = function()
			vim.wo.number = true
			vim.wo.relativenumber = true
			vim.wo.signcolumn = "yes:2"
		end,
	})
end

local telescope_loaded = false
local function load_and_remap_telescope()
	if telescope_loaded then
		return
	end
	telescope_loaded = true

	vim.pack.add({
		{ src = "https://github.com/nvim-telescope/telescope.nvim" },
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
	})

	local telescope = require("telescope")
	local Layout = require("telescope.pickers.layout_strategies")
	Layout.horizontal_merged = function(
		picker,
		max_columns,
		max_lines,
		layout_config
	)
		local layout =
			Layout.horizontal(picker, max_columns, max_lines, layout_config)
		layout.results.line = layout.results.line - 1
		layout.results.height = layout.results.height + 3
		layout.results.width = layout.results.width + 1
		layout.results.title = ""

		layout.prompt.line = layout.prompt.line + 1
		layout.prompt.width = layout.prompt.width + 1

		return layout
	end

	Layout.below_merged = function(
		picker,
		max_columns,
		max_lines,
		layout_config
	)
		local layout =
			Layout.vertical(picker, max_columns, max_lines, layout_config)
		layout.results.line = layout.results.line + 3
		layout.results.height = layout.results.height - 1
		layout.results.width = layout.results.width + 1
		layout.results.title = ""

		layout.prompt.line = layout.prompt.line + 1
		layout.prompt.width = layout.prompt.width + 1

		layout.preview.line = layout.preview.line - 1
		layout.preview.height = layout.preview.height + 5
		layout.preview.width = layout.preview.width + 1
		layout.preview.col = layout.preview.col - 1
		return layout
	end

	Layout.cursor_mini = function(picker, max_columns, max_lines, layout_config)
		local layout =
			Layout.cursor(picker, max_columns, max_lines, layout_config)
		layout.results.height = layout.results.height - 1
		layout.results.title = ""
		return layout
	end

	telescope.setup({
		defaults = {
			preview = { treesitter = false, title = "" },
			color_devicons = true,
			layout_strategy = "horizontal_merged",
			sorting_strategy = "descending",
			path_display = { "filename_first" },
			border = {
				preview = true,
				prompt = { 0, 0, 0, 1 },
				results = { 0, 0, 1, 1 },
			},
			borderchars = {
				preview = { " ", " ", " ", "┃", "┃", " ", " ", "┃" },
				prompt = empty_border,
				results = empty_border,
			},
			layout_config = {
				height = { padding = 0 },
				width = { padding = 0 },
				prompt_position = "bottom",
				preview_cutoff = 40,
			},
			preview_title = "",
		},
		pickers = {
			buffers = {
				mappings = {
					i = {
						["<C-x>"] = "delete_buffer",
					},
					n = {
						["<C-x>"] = "delete_buffer",
					},
				},
			},
		},
	})

	local builtin = require("telescope.builtin")

	local opts = {
		preview_title = "",
		results_title = "",
		prompt_title = "",
		layout_config = {
			preview_width = 0.5,
		},
	}

	local below = {
		preview = { treesitter = true },
		layout_strategy = "below_merged",
		border = {
			preview = { 0, 1, 0, 1 },
			prompt = { 1, 1, 0, 1 },
			results = { 1, 1, 0, 1 },
		},
		borderchars = {
			preview = empty_border,
			results = top_border,
			prompt = empty_border,
		},
		layout_config = {
			preview_cutoff = 0,
		},
		preview_title = "",
		results_title = "",
		prompt_title = "",
	}

	local cursor_float = {
		sorting_strategy = "ascending",
		layout_strategy = "cursor_mini",
		border = false,
		layout_config = {
			height = 11,
			width = math.floor(vim.api.nvim_win_get_width(0) / 3 + 18),
			prompt_position = "top",
			preview_cutoff = 400,
		},

		preview_title = "",
		results_title = "",
		prompt_title = "",
	}

	local pick_map = {
		["<leader>ff"] = builtin.find_files,
		["<leader>fo"] = builtin.oldfiles,
		["<leader>fr"] = builtin.lsp_references,
		["<leader>fd"] = builtin.diagnostics,
		["<leader>fI"] = builtin.lsp_implementations,
		["<leader>fT"] = builtin.lsp_type_definitions,
	}
	local pick_large_preview = {
		["<leader>fi"] = builtin.grep_string,
		["<leader>fh"] = builtin.help_tags,
		["<leader>fm"] = builtin.man_pages,
		["<leader>fk"] = builtin.keymaps,
		["<leader>fc"] = builtin.git_bcommits,
		["<leader>ft"] = builtin.builtin,
	}
	local below_map = {
		["<leader>fg"] = builtin.live_grep,
		["<leader>fb"] = builtin.buffers,
	}

	local cursor_map = {
		["<leader>fs"] = builtin.current_buffer_fuzzy_find,
	}

	bindmap(nmap, pick_map, opts, reset_highlights)

	bindmap(
		nmap,
		pick_large_preview,
		vim.tbl_extend(
			"force",
			opts,
			{ layout_config = { preview_width = 0.66 } }
		),
		reset_highlights
	)

	bindmap(nmap, below_map, below, replicate_buffer)

	bindmap(nmap, cursor_map, cursor_float, set_cursor_highlights)
end

local stub_map = {
	["<leader>fi"] = "Telescope picker: grep_string",
	["<leader>fo"] = "Telescope picker: oldfiles",
	["<leader>fh"] = "Telescope picker: help_tags",
	["<leader>fm"] = "Telescope picker: man_pages",
	["<leader>fr"] = "Telescope picker: lsp_references",
	["<leader>fd"] = "Telescope picker: diagnostics",
	["<leader>fI"] = "Telescope picker: lsp_implementations",
	["<leader>fT"] = "Telescope picker: lsp_type_definitions",
	["<leader>fs"] = "Telescope picker: current_buffer_fuzzy_find",
	["<leader>ft"] = "Telescope picker: builtin",
	["<leader>fc"] = "Telescope picker: git_bcommits",
	["<leader>fk"] = "Telescope picker: keymaps",
	["<leader>fg"] = "Telescope picker: live_grep",
	["<leader>ff"] = "Telescope picker: find_files",
	["<leader>fb"] = "Telescope picker: buffers",
}

for key, describe in pairs(stub_map) do
	utils.keymap_stub("n", key, load_and_remap_telescope, { desc = describe })
end
