local function load_venv_selector()
	require("venv-selector").setup({})
end

return {
	name = "venv-selector",
	load = load_venv_selector,
	src = "https://github.com/linux-cultist/venv-selector.nvim",
	ft = "python",
	libs = { "plenary" },
}
