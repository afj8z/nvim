local nmap = require("ajf.utils").nmap
local bindmap = require("defer").bind_map_pre_stub

local function load_and_remap_telescope()
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
		layout.results.height = layout.results.height + 2
		-- layout.results.col = layout.results.col + 1
		layout.prompt.width = layout.prompt.width + 1
		layout.results.width = layout.results.width + 1

		layout.preview.line = layout.preview.line - 1
		layout.preview.height = layout.preview.height + 2
		-- layout.preview.col = layout.preview.col - 1

		return layout
	end

	telescope.setup({
		defaults = {
			mappings = {
				n = { ["<C-h>"] = "which_key" },
			},
			preview = { treesitter = false },
			color_devicons = true,
			layout_strategy = "horizontal_merged",
			sorting_strategy = "ascending",
			path_display = { "smart" },
			border = {
				preview = false,
				prompt = { 1, 1, 1, 0 },
				results = { 1, 1, 0, 0 },
			},
			borderchars = { "", "", "", "", "", "", "", "" },
			-- borderchars = {
			-- 	prompt = { "", "", "", "", "", "", "", "" },
			-- 	results = { "", "", "─", "│", "│", "", "─", "└" },
			-- 	preview = { "─", "│", "─", " ", "─", "┐", "┘", "─" },
			-- },
			layout_config = {
				height = 0.8,
				width = 0.8,
				prompt_position = "top",
				preview_cutoff = 40,
			},
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
			find_files = {
				hidden = true,
			},
		},
		extensions = {
			media_files = {
				-- filetypes whitelist
				-- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
				filetypes = { "png", "webp", "jpg", "jpeg" },
				-- find command (defaults to `fd`)
				find_cmd = "rg",
			},
		},
	})

	local builtin = require("telescope.builtin")
	local _ = require("telescope").load_extension("media_files")

	local opts = {
		preview_title = false,
		results_title = false,
		-- prompt_title = false,
		layout_config = {
			preview_width = 0.6,
		},
	}

	local pick_map = {
		["<leader>ff"] = builtin.find_files,
		["<leader>fo"] = builtin.oldfiles,
		["<leader>fr"] = builtin.lsp_references,
		["<leader>fd"] = builtin.diagnostics,
		["<leader>fI"] = builtin.lsp_implementations,
		["<leader>fT"] = builtin.lsp_type_definitions,
		["<leader>fi"] = builtin.grep_string,
		["<leader>fh"] = builtin.help_tags,
		["<leader>fm"] = builtin.man_pages,
		["<leader>fk"] = builtin.keymaps,
		["<leader>fc"] = builtin.git_bcommits,
		["<leader>ft"] = builtin.builtin,
		["<leader>fg"] = builtin.live_grep,
		["<leader>fb"] = builtin.buffers,
		["<leader>fs"] = builtin.current_buffer_fuzzy_find,
		["<leader>fp"] = require("telescope").extensions.media_files.media_files,
	}

	bindmap(nmap, pick_map, opts)
end

return {
	name = "telescope",
	src = "https://github.com/nvim-telescope/telescope.nvim",
	load = load_and_remap_telescope,

	exts = {
		{
			"https://github.com/nvim-telescope/telescope-media-files.nvim.git",
		},
	},
	keys = {
		{ "n", "<leader>fi", desc = "Telescope picker: grep_string" },
		{ "n", "<leader>fo", desc = "Telescope picker: oldfiles" },
		{ "n", "<leader>fh", desc = "Telescope picker: help_tags" },
		{ "n", "<leader>fm", desc = "Telescope picker: man_pages" },
		{ "n", "<leader>fr", desc = "Telescope picker: lsp_references" },
		{ "n", "<leader>fd", desc = "Telescope picker: diagnostics" },
		{ "n", "<leader>fI", desc = "Telescope picker: lsp_implementations" },
		{ "n", "<leader>fT", desc = "Telescope picker: lsp_type_definitions" },
		{ "n", "<leader>fs", desc = "Telescope picker: current_buffer_fuzzy_find" },
		{ "n", "<leader>ft", desc = "Telescope picker: builtin" },
		{ "n", "<leader>fc", desc = "Telescope picker: git_bcommits" },
		{ "n", "<leader>fk", desc = "Telescope picker: keymaps" },
		{ "n", "<leader>fg", desc = "Telescope picker: live_grep" },
		{ "n", "<leader>ff", desc = "Telescope picker: find_files" },
		{ "n", "<leader>fb", desc = "Telescope picker: buffers" },
	},
	libs = { "plenary", "devicons" },
}
