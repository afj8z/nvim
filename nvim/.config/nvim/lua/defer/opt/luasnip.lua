local function load_luasnip()
	local utils = require("ajf.utils")
	local ls = require("luasnip")
	local types = require("luasnip.util.types")

	-- testcolors
	vim.api.nvim_set_hl(
		0,
		"TESTRED",
		{ bg = "#ff0000", fg = "#ffffff", bold = true }
	)
	vim.api.nvim_set_hl(
		0,
		"TESTYELLOW",
		{ bg = "#fff000", fg = "#ffffff", bold = true }
	)
	vim.api.nvim_set_hl(
		0,
		"TESTPURPLE",
		{ bg = "#ff00ff", fg = "#ffffff", bold = true }
	)
	vim.api.nvim_set_hl(
		0,
		"TESTCYAN",
		{ bg = "#00ffff", fg = "#ffffff", bold = true }
	)

	ls.setup({
		enable_autosnippets = true,
		store_selection_keys = "<Tab>",
		region_check_events = "CursorMoved",
		ext_opts = {
			[types.insertNode] = {
				active = {
					-- Highlight text when focused (requires text to be visible)
					hl_group = "TESTRED",
				},
				unvisited = {
					-- Use virtual text to show a marker for empty nodes
					virt_text = { { "●", "TESTCYAN" } },
					-- "inline" places the marker exactly where the cursor will jump.
					-- Use "overlay" or "eol" if you are on an older Neovim version.
					virt_text_pos = "inline",
				},
				visited = {
					hl_group = "TESTYELLOW",
				},
				-- 'passive' is the base for both visited and unvisited.
				-- We generally don't want virt_text on visited nodes, so we don't put it here.
				passive = {
					hl_group = "TESTPURPLE",
				},
			},
		},
	})

	require("luasnip.loaders.from_vscode").lazy_load()
	require("luasnip.loaders.from_lua").load({
		paths = "~/.config/nvim/lua/snippets",
	})

	local jump_snippet = function()
		if ls.locally_jumpable() and require("luasnip").in_snippet() then
			return ls.jump(1)
		else
			return "tab"
		end
	end

	utils.nmap(
		"tab",
		jump_snippet(),
		{ desc = "Jump to the next snippet node, if in an active snippet" }
	)
end

return {
	name = "luasnip",
	load = load_luasnip,
	src = {
		src = "https://github.com/L3MON4D3/LuaSnip",
		run = "make install_jsregexp",
	},
	exts = { "https://github.com/rafamadriz/friendly-snippets" },
}
