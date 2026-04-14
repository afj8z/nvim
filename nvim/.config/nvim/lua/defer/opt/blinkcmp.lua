local function load_blinkcmp()
	require("blink.cmp").setup({
		signature = { enabled = true },
		completion = {
			ghost_text = { enabled = false },
			documentation = { auto_show = true, auto_show_delay_ms = 150 },
			menu = {
				auto_show = true,
				-- max_height = 7,
				scrollbar = false,
				border = "none",
				draw = {
					treesitter = { "lsp" },
					columns = {

						{ "kind_icon", gap = 1 },
						{ "label", "label_description" },
					},
					-- components = {},
				},
			},
			list = {
				max_items = 70,
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
			["<Tab>"] = {
				function(cmp)
					if vim.fn.mode() == "t" then
						return
					end

					if cmp.snippet_active() then
						return cmp.accept()
					end

					if cmp.is_visible() then
						return cmp.select_and_accept()
					end

					return false
				end,
				"snippet_forward",
				"fallback",
			},
			["<C-e>"] = { "select_and_accept", "fallback" },
		},
		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},

		term = {
			enabled = false,
		},
		cmdline = {
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},
		appearance = {
			use_nvim_cmp_as_default = true,
		},
	})

	-- vim.api.nvim_create_autocmd("User", {
	-- 	pattern = "BlinkCmpMenuOpen",
	-- 	callback = function()
	-- 		vim.b.copilot_suggestion_hidden = true
	-- 	end,
	-- })
	--
	-- vim.api.nvim_create_autocmd("User", {
	-- 	pattern = "BlinkCmpMenuClose",
	-- 	callback = function()
	-- 		vim.b.copilot_suggestion_hidden = false
	-- 	end,
	-- })
end

return {
	name = "blinkcmp",
	src = {
		"https://github.com/Saghen/blink.cmp",
		version = "v1.6.0",
	},
	event = "InsertEnter",
	load = load_blinkcmp,
	deps = "luasnip",
	exts = { "https://github.com/xieyonn/blink-cmp-dat-word.git" },
}
