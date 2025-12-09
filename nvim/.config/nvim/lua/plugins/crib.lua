local empty_border = { "" }

require("crib").setup({
	path = "~/dev/cheatsheets",

	-- Inject your strategy safely when Crib loads Telescope
	on_load = function(T)
		-- T is the telescope module table passed by crib
		-- T.layout_strategies is require("telescope.pickers.layout_strategies")

		T.layout_strategies.horizontal_merged = function(
			picker,
			max_columns,
			max_lines,
			layout_config
		)
			local layout = T.layout_strategies.horizontal(
				picker,
				max_columns,
				max_lines,
				layout_config
			)

			-- Your custom border adjustments
			layout.results.line = layout.results.line - 1
			layout.results.height = layout.results.height + 3
			layout.results.width = layout.results.width + 1
			layout.results.title = ""

			layout.prompt.line = layout.prompt.line + 1
			layout.prompt.width = layout.prompt.width + 1

			return layout
		end
	end,

	-- Use the strategy you just defined above
	telescope = {
		layout_strategy = "horizontal_merged",

		prompt_title = "",
		results_title = "",
		preview_title = "",

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
	},
})

vim.keymap.set("n", "<leader>?", require("crib").show_cheatsheets, {})
