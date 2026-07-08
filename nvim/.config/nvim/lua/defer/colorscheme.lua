local function load_colorscheme()
	local clr = require("ajf.colors")
	require("nvim-tundra").setup({
		transparent_background = false,
		sidebar = { enabled = false },
	})
	vim.cmd("colorscheme tundra")

	vim.api.nvim_set_hl(0, "SnacksPicker", { link = "Normal", nocombine = true })
	vim.api.nvim_set_hl(
		0,
		"SnacksPickerPrompt",
		{ fg = clr.fg, bold = false, nocombine = true }
	)
	vim.api.nvim_set_hl(
		0,
		"SnacksPickerListCursorLine",
		{ bg = clr.fg, fg = clr.bg, nocombine = true }
	)
	vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = clr.bg, nocombine = true })
	vim.api.nvim_set_hl(0, "SnacksPickerPreview", { bg = clr.bg, nocombine = true })
	vim.api.nvim_set_hl(
		0,
		"SnacksPickerBorder",
		{ fg = clr.bg, bg = clr.bg, nocombine = true }
	)
end

return {
	name = "colorscheme",
	load = load_colorscheme,
}
