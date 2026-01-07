vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

local node_bin_path =
	vim.fn.expand("$HOME/.config/nvm/versions/node/v24.12.0/bin")

if vim.fn.isdirectory(node_bin_path) == 1 then
	vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH
end

local ts = require("nvim-treesitter.")

ts.install({
	"rust",
	"svelte",
	"rst",
	"typescript",
	"javascript",
	"bash",
	"css",
	"html",
	"json",
	"lua",
	"markdown",
	"regex",
	"markdown_inline",
	"tsx",
	"vim",
	"vimdoc",
	"luadoc",
	"python",
	"yaml",
	"kanata",
	"latex",
	"git_config",
	"hyprlang",
	"rasi",
	"c",
	"typst",
	"wim",
}, { summary = false }):wait(30000)

local enable_and_install_ts = function(event)
	local lang = vim.treesitter.language.get_lang(event.match) or event.match

	-- is parser installed?
	local has_parser = pcall(vim.treesitter.get_parser, event.buf, lang)

	if not has_parser then
		-- node not in system $PATH, so ensure nvim can reach it
		if vim.fn.executable("node") == 1 or vim.fn.executable("npm") == 1 then
			local ok, task = pcall(ts.install, { lang }, { summary = true })
			if ok then
				task:wait(10000)
			end
		else
			vim.print("node.js not in path, check config")
			return
		end
	end

	-- Attempt to start highlighting
	pcall(vim.treesitter.start, event.buf, lang)
end

vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = function()
		require("nvim-treesitter.parsers").kanata = {
			install_info = {
				path = "~/src/tree-sitter-kanata",
				-- optional entries
				-- generate = true,
				generate_from_json = false,
				queries = "queries/neovim", -- symlink queries from given directory
			},
		}
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ui.treesitter", { clear = true }),
	pattern = { "*" },
	callback = enable_and_install_ts,
})

vim.filetype.add({
	extension = { kbd = "kbd", rasi = "rasi", rofi = "rasi", wofi = "rasi" },
	filename = {
		["vifmrc"] = "vim",
	},
	pattern = {
		[".*/waybar/config"] = "jsonc",
		[".*/kitty/.+%.conf"] = "kitty",
		[".*/hypr/.+%.conf"] = "hyprlang",
		["%.env%.[%w_.-]+"] = "sh",
	},
})

vim.treesitter.language.register("kanata", "kbd")

vim.treesitter.language.register("bash", "kitty")
