local utils = require("ajf.utils")
local c = require("ajf.colors")
local nmap = utils.nmap
local bindmap = utils.bind_map_pre_stub

local telescope_loaded = false
local function load_and_remap_telescope()
	if telescope_loaded then
		return
	end
	telescope_loaded = true

	vim.pack.add({
		{ src = "https://github.com/nvim-telescope/telescope.nvim" },
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
		{ src = "https://github.com/nvim-tree/nvim-web-devicons.git" },
	})

	local telescope = require("telescope")

	telescope.setup({
		defaults = {
			preview = { treesitter = false },
			color_devicons = true,
			sorting_strategy = "ascending",
			path_display = { "smart" },
			borderchars = { "", "", "", "", "", "", "", "" },
			layout_config = {
				height = 100,
				width = 400,
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
	})

	local builtin = require("telescope.builtin")

	local opts = {
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
	}

	bindmap(nmap, pick_map, opts)
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
