local function load_oil()
	local sym = require("ajf.style").icons.diagnostics
	local style = require("ajf.utils").get_settings()

	require("oil").setup({
		default_file_explorer = true,
		columns = {
			-- "icon",
			"permissions",
			"size",
			"mtime",
		},
		skip_confirm_for_simple_edits = false,
		prompt_save_on_select_new_entry = true,
		constrain_cursor = "name",
		view_options = {
			show_hidden = true,
			is_hidden_file = function(name, bufnr)
				local fts = {
					"pdf",
					"svg",
					"jpeg",
					"jpg",
					"png",
					"o",
				}
				for _, ft in ipairs(fts) do
					local m = name:match("%." .. ft .. "$")
					if m then
						return m ~= nil
					end
				end
				local m = name:match("^%.")
				return m ~= nil
			end,
			sort = {
				{ "type", "asc" },
				{ "name", "asc" },
			},
		},
		float = {
			border = style.border,
			preview_split = "right",
		},
		preview_win = {
			update_on_cursor_moved = true,
			preview_method = "fast_scratch",
		},
		confirmation = {
			border = style.border,
		},
		progress = {
			border = style.border,
		},
		ssh = {
			border = style.border,
		},
		keymaps = {
			["q"] = {
				desc = "Close Oil and restore previous buffer (keep tab)",
				callback = function()
					local alt_buf = vim.fn.bufnr("#")

					-- check if alternate buffer exists, is valid, and is listed
					if
						alt_buf ~= -1
						and vim.api.nvim_buf_is_valid(alt_buf)
						and vim.bo[alt_buf].buflisted
					then
						vim.cmd("buffer #")
					else
						-- fallback if opened in a fresh tab: inject a scratch buffer
						local scratch_buf = vim.api.nvim_create_buf(false, true)
						vim.bo[scratch_buf].bufhidden = "wipe"
						vim.api.nvim_win_set_buf(0, scratch_buf)
					end
				end,
			},
			["<C-'>"] = {
				"actions.select",
				opts = { horizontal = true, split = "botright" },
			},
			["<C-S-%>"] = { "actions.select", opts = { vertical = true } },
			["<C-j>"] = "actions.select",
			["."] = { "actions.toggle_hidden", mode = "n" },
		},
		keymaps_help = {
			border = style.border,
		},
	})

	require("oil-lsp-diagnostics").setup({
		diagnostic_symbols = {
			error = sym.ERROR,
			warn = sym.WARN,
			info = sym.INFO,
			hint = sym.HINT,
		},
	})
end

return {
	name = "oil",
	src = "https://github.com/stevearc/oil.nvim",
	exts = {
		{ "https://github.com/JezerM/oil-lsp-diagnostics.nvim" },
		{
			"https://github.com/malewicz1337/oil-git.nvim.git",
			run = {
				name = "oil-git",
				opts = {
					show_file_highlights = false,
					show_directory_highlights = false,
					symbol_position = "signcolumn",
				},
			},
		},
	},
	cmds = "Oil",
	load = load_oil,
	libs = "devicons",
}
