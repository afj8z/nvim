local function load_luasnip()
	local utils = require("ajf.utils")
	local ls = require("luasnip")
	local types = require("luasnip.util.types")
	local colors = require("ajf.colors")

	-- testcolors
	vim.api.nvim_set_hl(0, "__LuasnipActSnip", { bg = colors.comment })
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
					-- virt_text = { { "●", "DiagnosticInfo" } },
				},
				unvisited = {

					virt_text = { { "●", "DiagnosticInfo" } },
					virt_text_pos = "inline",
				},
				-- visited = {
				-- 	hl_group = "Comment",
				-- },
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
