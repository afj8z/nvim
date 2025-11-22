local utils = require("ajf.utils")

utils.lazy_on_filetype("TypstPreview", { "typst" }, function()
	vim.cmd("packadd typst-preview.nvim")
	require("typst-preview").setup({
		dependencies_bin = { ["tinymist"] = "tinymist" },
		open_cmd = 'firefox --new-window --no-remote -P "preview-profile" %s',
		invert_colors = "never",
		follow_cursor = true,
	})
end)
