local function load_zen()
	require("zen-mode").setup({
		window = {
			width = 0.8,
			options = {
				number = false,
				cursorline = true,
				list = true,
				scrolloff = 999,
				wrap = true,
				columns = 84,
			},
		},
		plugins = { options = { laststatus = 0 } },
		on_open = function(win)
			os.execute("tmux set status off")
			os.execute("somebar -s /tmp/mybar -c hide all")
			vim.keymap.set({ "n", "v" }, "j", "gj")
			vim.keymap.set({ "n", "v" }, "k", "gk")
		end,
		on_close = function()
			os.execute("tmux set status on")
			os.execute("somebar -s /tmp/mybar -c show all")
			vim.keymap.del({ "n", "v" }, "j")
			vim.keymap.del({ "n", "v" }, "k")
		end,
	})
end
return {
	name = "zen-mode",
	src = "https://github.com/folke/zen-mode.nvim.git",
	exts = { "https://github.com/folke/twilight.nvim.git" },
	load = load_zen,
	cmds = {
		"ZenMode",
	},
}
