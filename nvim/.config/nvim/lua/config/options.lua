local style = require("ajf.utils").get_settings()

local options = {
	opt = {
		conceallevel = 0,
		concealcursor = "c",
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
		spelllang = "en_us,de_de",
		completeopt = { "menu", "menuone", "noselect" },
		guicursor = "n-v-c:block,i-ci-r:block-blinkwait0-blinkoff500-blinkon50-Cursor/lCursor,o:hor10-Cursor",
		iskeyword = "@,48-57,192-255",
		laststatus = 2,
		fillchars = "horiz:━,vert:┃,horizup:┻,horizdown:┳,vertleft:┫,vertright:┣,verthoriz:╋",
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

Defer.set.setopts(options)

local append = {
	wildignore = ".doc,*.pdf,*.cbr,*.cbz,.o,*.obj,*.exe,*.dll",
}
Defer.set.appendopts(append)

vim.cmd("set updatetime=750")
