local utils = require("ajf.utils")
local style = utils.get_settings()
local sym = require("ajf.style").icons.diagnostics
local diagnostic = vim.diagnostic
local map = vim.keymap.set

-- list of filetypes to trigger LSP loading
local lsp_filetypes = {
	"python",
	"lua",
	"rust",
	"sh",
	"zsh",
	"bash",
	"c",
	"cpp",
	"javascript",
	"typescript",
	"javascriptreact",
	"typescriptreact",
	"json",
	"toml",
	"typst",
	"markdown",
	"html",
	"css",
	"rst",
	"kbd",
	"sql",
}

local function load_lsp()
	-- LspAttach keymaps (Must be defined before servers attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
			local opts = { buffer = ev.buf }
			map("n", "gr", vim.lsp.buf.references, opts)
			map("n", "gd", vim.lsp.buf.definition, opts)
			map("n", "<leader>dn", vim.lsp.buf.rename, opts)
			map("n", "<leader>da", vim.lsp.buf.code_action, opts)
			map("n", "<leader>dd", function()
				vim.diagnostic.open_float({
					border = style.border,
				})
			end, opts)
			map("n", "<space>dt", function()
				vim.lsp.inlay_hint.enable(
					not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }),
					{ bufnr = 0 }
				)
			end, opts)
		end,
	})

	-- This will trigger the actual server setups
	vim.schedule(function()
		-- specific check to ensure buffer is still valid and needs this
		local buf = vim.api.nvim_get_current_buf()
		if buf and vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_exec_autocmds(
				"FileType",
				{ buffer = buf, modeline = false }
			)
		end
	end)

	vim.diagnostic.config({
		underline = true,
		virtual_text = false,
		virtual_lines = false,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = sym.ERROR,
				[vim.diagnostic.severity.WARN] = sym.WARN,
				[vim.diagnostic.severity.INFO] = sym.INFO,
				[vim.diagnostic.severity.HINT] = sym.HINT,
			},
		},
		severity_sort = true,
		float = {
			source = true,
			scope = "line",
			header = "Diagnostics:",
			prefix = " ",
			border = style.border,
		},
	})

	local set_qflist = function(buf_num, severity)
		local diagnostics = nil
		diagnostics = diagnostic.get(buf_num, { severity = severity })
		local qf_items = diagnostic.toqflist(diagnostics)
		vim.fn.setqflist({}, " ", { title = "Diagnostics", items = qf_items })
		vim.cmd([[copen]])
	end

	map(
		"n",
		"<space>dw",
		diagnostic.setqflist,
		{ desc = "put window diagnostics to qf" }
	)
	map("n", "<space>db", function()
		set_qflist(0)
	end, { desc = "put buffer diagnostics to qf" })

	map("n", "<leader>de", function()
		set_qflist(0, "error")
	end)

	local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
	---@diagnostic disable-next-line: duplicate-set-field
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.focus = true
		opts.anchor_bias = "below"
		opts.max_height = 11
		opts.max_width = 80
		return orig_util_open_floating_preview(contents, syntax, opts, ...)
	end
end

return {
	name = "lsp",
	load = load_lsp,
	src = "https://github.com/neovim/nvim-lspconfig",
	ft = lsp_filetypes,
	-- deps = { "mason" }, -- force mason to load prior to lsp attach
}
