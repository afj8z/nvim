local utils = require("ajf.utils")

utils.lazy_on_event(
	"Treesitter",
	{ "BufReadPost", "BufNewFile" },
	function(args)
		vim.pack.add({
			{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
		})

		local node_bin_path =
			vim.fn.expand("$HOME/.config/nvm/versions/node/v24.12.0/bin")

		if vim.fn.isdirectory(node_bin_path) == 1 then
			vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH
		end

		local ts = require("nvim-treesitter.install")

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
			"sql",
		}, { summary = false }):wait(30000)

		local enable_and_install_ts = function(buf, ft)
			if not ft or ft == "" then
				return
			end

			local lang = vim.treesitter.language.get_lang(ft) or ft
			local has_parser = pcall(vim.treesitter.get_parser, buf, lang)

			if not has_parser then
				if vim.fn.executable("node") == 1 then
					-- FIX: Use ts_install here
					local ok, task = pcall(
						ts.install,
						{ lang },
						{ summary = true }
					)
					if ok then
						task:wait(10000)
					end
				else
					vim.notify("Node.js not found", vim.log.levels.WARN)
					return
				end
			end

			-- Start highlighting
			pcall(vim.treesitter.start, buf, lang)
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
			group = vim.api.nvim_create_augroup(
				"ui.treesitter",
				{ clear = true }
			),
			pattern = "*",
			callback = function(ev)
				enable_and_install_ts(ev.buf, ev.match)
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

		vim.treesitter.language.register("kanata", "kbd")

		vim.treesitter.language.register("bash", "kitty")

		-- Trigger treesitter for first buffer (allows
		-- my lazy loading)
		local current_ft = vim.bo[args.buf].filetype
		enable_and_install_ts(args.buf, current_ft)
	end
)
