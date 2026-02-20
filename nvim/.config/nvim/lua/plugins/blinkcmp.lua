local utils = require("ajf.utils")

utils.lazy_on_event("BlinkCmp", "InsertEnter", function()
	vim.pack.add({
		{ src = "https://github.com/xieyonn/blink-cmp-dat-word.git" },
		{
			src = "https://github.com/L3MON4D3/LuaSnip",
			run = "make install_jsregexp",
		},
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
		{
			src = "https://github.com/Saghen/blink.cmp",
			version = "v1.6.0",
		},
	})

	local ls = require("luasnip")
	local types = require("luasnip.util.types")

	-- Define your colors
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

	require("blink.cmp").setup({
		signature = { enabled = true },
		completion = {
			ghost_text = { enabled = true },
			documentation = { auto_show = true, auto_show_delay_ms = 0 },
			menu = {
				auto_show = true,
				max_height = 7,
				border = "none",
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind" },
					},
				},
			},
			list = {
				selection = {
					preselect = false,
					auto_insert = true,
				},
			},
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "datword" },
			providers = {
				lsp = {
					timeout_ms = 10000,
				},
				datword = {
					name = "Word",
					module = "blink-cmp-dat-word",
					opts = {
						paths = require("ajf.userfunc").get_local_word_dict(
							"~/lib/dict/words.txt"
						),
					},
				},
			},
		},
		keymap = {
			["<C-l>"] = { "select_and_accept", "fallback" },
		},
		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},

		term = {
			enabled = true,
		},
		cmdline = {
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},
		appearance = {
			use_nvim_cmp_as_default = false,
		},
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

	vim.api.nvim_create_autocmd("User", {
		pattern = "BlinkCmpMenuOpen",
		callback = function()
			vim.b.copilot_suggestion_hidden = true
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "BlinkCmpMenuClose",
		callback = function()
			vim.b.copilot_suggestion_hidden = false
		end,
	})
end)
