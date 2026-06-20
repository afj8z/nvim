local function load_blinkcmp()
	local cmp = require("blink.cmp")
	cmp.build():pwait()
	cmp.setup({
		signature = { enabled = true },
		completion = {
			ghost_text = { enabled = false },
			documentation = { auto_show = true, auto_show_delay_ms = 0 },
			menu = {
				auto_show = true,
				-- max_height = 7,
				scrollbar = false,
				border = "none",
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "kind", gap = 1 },
						{ "label", "label_description" },
					},
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
			default = { "lsp", "snippets", "buffer", "path", "datword" },
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
end

return {
	name = "blinkcmp",
	src = {
		"https://github.com/Saghen/blink.cmp",
		-- version = "v1.6.0",
	},
	event = "InsertEnter",
	load = load_blinkcmp,
	deps = "luasnip",
	libs = "blinklib",
	exts = { "https://github.com/xieyonn/blink-cmp-dat-word.git" },
}
