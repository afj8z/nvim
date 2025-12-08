require("crib").setup({
	path = "~/dev/cheatsheets",
})

vim.keymap.set("n", "<leader>?", require("crib").show_cheatsheets, {})
