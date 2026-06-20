local function load_luasnip()
	local utils = require("ajf.utils")
	local ls = require("luasnip")
	local types = require("luasnip.util.types")

	ls.setup({
		enable_autosnippets = true,
		store_selection_keys = "<Tab>",
		region_check_events = "CursorMoved",
		ext_opts = {
			[types.insertNode] = {
				active = {

					hl_group = "LuaSnipAct",
				},
				unvisited = {
					hl_group = "LuaSnipUnv",
					virt_text = { { " ", "LuaSnipUnv" } },
					virt_text_pos = "inline",
				},
			},
			[types.exitNode] = {
				unvisited = {
					hl_group = "LuaSnipUnv",
					virt_text = { { " ", "LuaSnipUnv" } },
					virt_text_pos = "inline",
				},
			},
		},
	})

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
