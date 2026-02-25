local function load_typstpv()
	require("typst-preview").setup({
		dependencies_bin = { ["tinymist"] = "tinymist" },
		open_cmd = 'firefox --new-window --no-remote -P "previewer" %s',
		invert_colors = "never",
		follow_cursor = true,
	})
	-- from plugin/init.lua, wont register commands otherwise
	require("typst-preview.commands").create_commands()
	require("typst-preview.events").init()
end

return {
	name = "typst-preview",
	src = "https://github.com/chomosuke/typst-preview.nvim",
	ft = "typst",
	load = load_typstpv,
}
