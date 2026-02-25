local function load_surround()
	require("mini.surround").setup({})
end
return {
	name = "mini-surround",
	src = { src = "https://github.com/nvim-mini/mini.surround.git" },
	load = load_surround,
}
