local utils = require("ajf.utils")

utils.lazy_on_filetype("TypstPreview", { "typst" }, function()
	vim.pack.add({
		{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	})

	require("typst-preview").setup({
		dependencies_bin = { ["tinymist"] = "tinymist" },
		open_cmd = 'firefox --new-window --no-remote -P "preview-profile" %s',
		invert_colors = "never",
		follow_cursor = true,
	})
	-- from plugin/init.lua, wont register commands otherwise
	require("typst-preview.commands").create_commands()
	require("typst-preview.events").init()
end)
