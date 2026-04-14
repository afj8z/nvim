local function load_treesitter()
	-- local ts = require("nvim-treesitter.install")
	local ft_to_parse = {
		"make",
		"toml",
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
		"latex",
		"git_config",
		"hyprlang",
		"rasi",
		"c",
		"cpp",
		"typst",
		"sql",
		"kbd",
	}

	-- ts.install(ft_to_parse, { summary = false }):wait(30000)

	-- local enable_and_install_ts = function(buf, ft)
	-- 	if not ft or ft == "" then
	-- 		return
	-- 	end
	--
	-- 	local lang = vim.treesitter.language.get_lang(ft) or ft
	-- 	local has_parser = pcall(vim.treesitter.get_parser, buf, lang)
	--
	-- 	if not has_parser then
	-- 		if vim.fn.executable("node") == 1 then
	-- 			local ok, task = pcall(ts.install, { lang }, { summary = true })
	-- 			if ok then
	-- 				task:wait(10000) end
	-- 		else
	-- 			vim.notify("Node.js not found", vim.log.levels.WARN)
	-- 			return
	-- 		end
	-- 	end
	--
	-- 	-- Start highlighting
	-- 	pcall(vim.treesitter.start, buf, lang)
	-- end

	-- vim.api.nvim_create_autocmd("FileType", {
	-- 	group = vim.api.nvim_create_augroup("ui.treesitter", { clear = true }),
	-- 	pattern = ft_to_parse,
	-- 	callback = function(ev)
	-- 		-- enable_and_install_ts(ev.buf, ev.match)
	-- 	end,
	-- })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft_to_parse,
		callback = function()
			vim.treesitter.start()
		end,
	})

	vim.filetype.add({
		extension = {
			kbd = "kbd",
			rasi = "rasi",
			rofi = "rasi",
			wofi = "rasi",
		},
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

	-- Trigger treesitter for the current buffer dynamically
	-- local current_buf = vim.api.nvim_get_current_buf()
	-- local current_ft = vim.bo[current_buf].filetype
	-- enable_and_install_ts(current_buf, current_ft)
	-- Remove the vim.api.nvim_create_autocmd("User", { pattern = "TSUpdate", ... }) block

	vim.api.nvim_create_autocmd("User", {
		pattern = "TSUpdate",
		callback = function()
			require("nvim-treesitter.parsers").kanata = {
				install_info = {
					path = "/home/aidanfleming/src/tree-sitter-kanata", -- Local directory
					files = { "src/parser.c" },
					generate = false,
				},
			}
			require("nvim-treesitter.parsers").wonkey = {
				install_info = {
					path = "/home/aidanfleming/dev/wonkey_parser/", -- Local directory
					files = { "src/parser.c" },
					generate = false,
				},
			}
		end,
	})

	vim.filetype.add({
		extension = {
			kbd = "kanata",
			h = "c",
		},
	})

	vim.treesitter.language.register("kanata", "kbd")
	vim.treesitter.language.register("wonkey", "wonkey")
end

return {
	name = "treesitter",
	src = "https://github.com/nvim-treesitter/nvim-treesitter",
	load = load_treesitter,
}
