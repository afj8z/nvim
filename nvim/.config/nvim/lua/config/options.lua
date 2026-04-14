local style = require("ajf.utils").get_settings()
local vc = vim.cmd

local options = {
	opt = {
		conceallevel = 0,
		concealcursor = "nc",
		wrap = false,
		tabstop = 4,
		shiftwidth = 4,
		smartindent = true,
		number = true,
		cursorcolumn = false,
		relativenumber = true,
		signcolumn = "yes:1",
		termguicolors = true,
		scrolloff = 4,
		showmode = false,
		undofile = true,
		swapfile = false,
		winborder = style.border,
		pumborder = style.border,
		splitright = true,
		clipboard = "unnamedplus",
		inccommand = "split",
		incsearch = true,
		ignorecase = true,
		smartcase = true,
		hlsearch = true,
		title = true,
		completeopt = { "menu", "menuone", "noselect" },
		guicursor = "n-v-c:block,i-ci-r:block-blinkwait0-blinkoff50-blinkon50-Cursor/lCursor,o:hor10-Cursor",
		iskeyword = "@,48-57,192-255",
	},
	g = {
		have_nerd_font = true,
		clipboard = "wl-copy",
		tundra_biome = "custom",
		color_pp = "alt",
		loaded_netrw = 1,
		loaded_netrwPlugin = 1,
		loaded_gzip = 1,
		loaded_zip = 1,
		loaded_zipPlugin = 1,
		loaded_tar = 1,
		loaded_tarPlugin = 1,
		loaded_tutor = 1,
	},
}

for scope, set in pairs(options) do
	for k, v in pairs(set) do
		vim[scope][k] = v
	end
end

vc("set updatetime=750")
vc("colorscheme tundra")
