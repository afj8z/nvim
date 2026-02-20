local utils = require("ajf.utils")
local nmap = utils.nmap

local aerial_loaded = false
local function load_and_remap_aerial()
	if aerial_loaded then
		return
	end
	aerial_loaded = true

	vim.pack.add({
		{ src = "https://github.com/stevearc/aerial.nvim.git" },
	})
	local custom_syms = {
		["Heading"] = {
			reg = 255,
			hl = { fg = "Function" },
		},
		["FCall"] = 254,
	}

	for k, v in pairs(custom_syms) do
		if not vim.lsp.protocol.SymbolKind[k] then
			local i = type(v) == table and v.reg or v
			vim.lsp.protocol.SymbolKind[k] = i
			vim.lsp.protocol.SymbolKind[i] = k
		end
	end
	local include_syms = {
		"Array",
		"Boolean",
		"Class",
		"Constant",
		"Constructor",
		"Enum",
		"EnumMember",
		"Event",
		"Field",
		"File",
		"Function",
		"Interface",
		"Key",
		"Method",
		"Module",
		"Namespace",
		"Null",
		"Number",
		"Object",
		"Operator",
		"Package",
		"Property",
		"String",
		"Struct",
		"TypeParameter",
		"Variable",
	}
	for k, _ in pairs(custom_syms) do
		vim.list_extend(include_syms, { k })
	end
	local my_icons = {}
	local collapsed = "> "
	for k, v in pairs(require("ajf.style").icons.symbol_kinds) do
		for i = 1, #include_syms do
			if include_syms[i] == k then
				my_icons[k] = v.icon
				my_icons[k .. "Collapsed"] = collapsed .. v.icon
			end
		end
	end

	-- Setup Icon Highlights
	for _, k in pairs(include_syms) do
		local icon_data = require("ajf.style").icons.symbol_kinds[k]
		if icon_data then
			local custom_def = custom_syms[k]
			local applied_bg = nil

			-- 1. Determine the target Background color based on 'rev'
			if type(custom_def) == "table" and custom_def.hl then
				if custom_def.hl.rev then
					-- If Reversed: Icon BG comes from the source 'fg' group (inheriting its fg color)
					-- Matches your text logic: opts.bg = ...name=def.hl.fg... .fg
					if custom_def.hl.fg then
						applied_bg = vim.api.nvim_get_hl(
							0,
							{ name = custom_def.hl.fg, link = false }
						).fg
					end
				else
					-- Normal: Icon BG comes from the source 'bg' group (inheriting its bg color)
					if custom_def.hl.bg then
						applied_bg = vim.api.nvim_get_hl(
							0,
							{ name = custom_def.hl.bg, link = false }
						).bg
					end
				end
			end

			-- 2. Apply the Highlight
			if applied_bg then
				-- Keep standard icon Foreground, but force the calculated Background
				local standard_fg = vim.api.nvim_get_hl(
					0,
					{ name = icon_data.hl, link = false }
				).fg

				vim.api.nvim_set_hl(0, "Aerial" .. k .. "Icon", {
					fg = standard_fg,
					bg = applied_bg,
				})
			else
				-- Fallback: Just link to the standard icon group
				vim.api.nvim_set_hl(
					0,
					"Aerial" .. k .. "Icon",
					{ link = icon_data.hl }
				)
			end
		end
	end

	_G.get_aerial_lineno = function()
		local aer_bufnr = vim.api.nvim_get_current_buf()
		local src_bufnr = vim.b[aer_bufnr].source_buffer

		if not src_bufnr then
			return ""
		end

		local ok, aerial_data = pcall(require, "aerial.data")
		if not ok then
			return ""
		end

		local bufdata = aerial_data.get(src_bufnr)
		if not bufdata then
			return ""
		end

		local item = bufdata:item(vim.v.lnum)

		if item then
			return tostring(item.lnum)
		end

		return ""
	end

	require("aerial").setup({
		filter_kind = include_syms,
		icons = my_icons,
		show_guides = true,
		post_add_all_symbols = function(bufnr, items, ctx)
			if ctx.lang ~= "typst" then
				return items
			end

			local function add_padding(list, depth)
				depth = depth or 0
				for _, item in ipairs(list) do
					-- Calculate padding needed to stretch background
					-- We assume a wide width (120) to cover the sidebar
					local pad_target = 120
					local current_len = string.len(item.name)

					if pad_target > current_len then
						item.name = item.name
							.. string.rep(" ", pad_target - current_len)
					end

					if item.children then
						add_padding(item.children, depth + 1)
					end
				end
			end

			add_padding(items)
			return items
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "aerial",
		callback = function()
			vim.opt_local.statuscolumn = "%=%{v:lua.get_aerial_lineno()} "

			vim.opt_local.signcolumn = "no"
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
		end,
	})

	for kind, def in pairs(custom_syms) do
		if type(def) == "table" and def.hl then
			local opts = {}
			if def.hl.rev then
				if def.hl.fg then
					opts.bg = vim.api.nvim_get_hl(
						0,
						{ name = def.hl.fg, link = false }
					).fg
				end

				-- 2. Take the BG color of the source (e.g. "NormalFloat" hex)
				--    and assign it to the FG of the Aerial symbol.
				if def.hl.bg then
					opts.fg = vim.api.nvim_get_hl(
						0,
						{ name = def.hl.bg, link = false }
					).bg
				end
			else
				if def.hl.fg then
					opts.fg = vim.api.nvim_get_hl(
						0,
						{ name = def.hl.fg, link = false }
					).fg
				end
				if def.hl.bg then
					opts.bg = vim.api.nvim_get_hl(
						0,
						{ name = def.hl.bg, link = false }
					).bg
				end
			end

			vim.api.nvim_set_hl(0, "Aerial" .. kind, opts)
		end
	end

	nmap("}", ":AerialNext<CR>", { desc = "Goto next Symbol" })
	nmap("{", ":AerialPrev<CR>", { desc = "Goto previous Symbol" })
	nmap("<leader>o", ":AerialToggle<CR>", { desc = "Show file Outline" })
	nmap(
		"<leader>/",
		":AerialNavToggle<CR>",
		{ desc = "Show file Outline Navigation Window" }
	)
end

utils.command_stub("AerialToggle", load_and_remap_aerial)

local kmap = {
	["}"] = "Goto next Symbol in Outline",
	["{"] = "Goto previous Symbol in Outline",
	["<leader>o"] = "Show file Outline",
	["<leader>/"] = "Show file Outline Navigation Window",
}

for k, v in pairs(kmap) do
	utils.keymap_stub("n", k, load_and_remap_aerial, { desc = v })
end
