local utils = require("utils")

local fzf_loaded = false
local function load_and_remap_fzf()
	if fzf_loaded then
		return
	end
	fzf_loaded = true

	vim.pack.add({
		{ src = "https://github.com/ibhagwan/fzf-lua.git" },
	})

	local fzf_lua = require("fzf-lua")
	local colors = require("colors")

	local tabline_h = (vim.o.showtabline > 0 and 1 or 0)
	local statusline_h = (vim.o.laststatus > 0 and 1 or 0)
	local cmdline_h = vim.o.cmdheight

	local available_height = vim.o.lines - tabline_h - statusline_h - cmdline_h
	local start_row = tabline_h

	local win_height = available_height
	local win_width = vim.o.columns

	require("fzf-lua").setup({
		fzf_opts = {
			["--wrap"] = false,
			["ansi"] = false,
		},
		previewers = {
			builtin = {
				syntax_limit_b = -102400,
				treesitter = {
					enabled = false,
				},
			},
		},
		fzf_colors = true,
		grep = {
			rg_glob = true,
			rg_glob_fn = function(query, opts)
				local regex, flags = query:match("^(.-)%s%-%-(.*)$")
				return (regex or query), flags
			end,
		},
		defaults = {
			git_icons = false,
			file_icons = false,
			color_icons = false,
			formatter = "path.filename_first",
		},
		keymap = {
			fzf = {
				true,
				-- Use <c-q> to select all items and add them to the quickfix list
				["ctrl-q"] = "select-all+accept",
			},
		},
		fzf_args = {
			'--input-border="none" ',
			'--list-border="none" ',
			'--footer-border="none" ',
			'--header-border="none"',
			'--padding="0" ',
			'--margin="0" ',
			'--scrollbar="" ',
			"--color=gutter:-1",
		},
	})

	vim.api.nvim_set_hl(0, "FzfLuaBorder", { link = "FloatBorder" })
	vim.api.nvim_set_hl(0, "FzfLuaTitle", { link = "FloatBorder" })
	vim.api.nvim_set_hl(0, "FzfLuaFzfGutter", { link = "Normal" })

	local _fullscreen = {
		fzf_opts = {

			["--layout"] = "default",
		},
		winopts = {
			preview = {
				wrap = false,
				layout = "horizontal",
				horizontal = "right:40%",
				border = "none",
			},
			height = win_height,
			width = win_width,
			backdrop = 100,
			border = "none",
		},
	}

	local nmap = function(lhs, rhs, opt)
		vim.keymap.set("n", lhs, rhs, opt)
	end

	nmap("<leader>ff", function()
		fzf_lua.files(_fullscreen)
	end, { desc = "FZF Files" })

	nmap("<leader>fg", function()
		fzf_lua.live_grep(_fullscreen)
	end, { desc = "FZF Grep" })

	nmap("<leader>fb", function()
		fzf_lua.buffers(_fullscreen)
	end, { desc = "FZF Buffers" })

	nmap("<leader>fh", function()
		fzf_lua.helptags({ fzf_opts = { ["--input-label"] = " Helptags " } })
	end, { desc = "Help Tags" })
	nmap("<leader>fm", function()
		fzf_lua.marks({ fzf_opts = { ["--input-label"] = " Marks " } })
	end, { desc = "Marks" })
	nmap("<leader>fr", function()
		fzf_lua.registers({ fzf_opts = { ["--input-label"] = " Registers " } })
	end, { desc = "Registers" })
	nmap("<leader>fF", function()
		fzf_lua.resume({ fzf_opts = { ["--input-label"] = " Resume " } })
	end, { desc = "FZF Resume" })
	nmap("<leader>fu", function()
		fzf_lua.changes({ fzf_opts = { ["--input-label"] = " Changes " } })
	end, { desc = "FZF Changes" })
	nmap("<leader>ft", function()
		fzf_lua.tmux_buffers({ fzf_opts = { ["--input-label"] = " Tmux " } })
	end, { desc = "FZF Tmux" })
	nmap("<leader>fv", function()
		fzf_lua.files({ cwd = "~/.config/nvim", fzf_opts = { ["--input-label"] = " Nvim Config " } })
	end)
end

utils.keymap_stub("n", "<leader>ff", load_and_remap_fzf, { desc = "FZF Files" })
utils.keymap_stub("n", "<leader>fg", load_and_remap_fzf, { desc = "FZF Grep" })
utils.keymap_stub("n", "<leader>fb", load_and_remap_fzf, { desc = "FZF Buffers" })
utils.keymap_stub("n", "<leader>fh", load_and_remap_fzf, { desc = "Help Tags" })
utils.keymap_stub("n", "<leader>fm", load_and_remap_fzf, { desc = "Marks" })
utils.keymap_stub("n", "<leader>fr", load_and_remap_fzf, { desc = "Registers" })
utils.keymap_stub("n", "<leader>fF", load_and_remap_fzf, { desc = "FZF Resume" })
utils.keymap_stub("n", "<leader>fu", load_and_remap_fzf, { desc = "FZF Changes" })
utils.keymap_stub("n", "<leader>ft", load_and_remap_fzf, { desc = "FZF Tmux" })
utils.keymap_stub("n", "<leader>fv", load_and_remap_fzf, { desc = "Nvim Config" })
