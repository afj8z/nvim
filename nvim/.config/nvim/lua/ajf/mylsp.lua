local diagnostic = vim.diagnostic
local map = vim.keymap.set
local sym = require("ajf.icons").diagnostics
local style = require("ajf.utils").get_settings()

vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})
require("mason").setup()
require("mason-lspconfig").setup({})
require("mason-tool-installer").setup({
	ensure_installed = {
		"clangd",
		"rust-analyzer",
		"basedpyright",
		"lua_ls",
		"tombi",
		"biome",
		"rstcheck",
		"tinymist",
		"typstyle",
		"emmet_ls",
		"bashls",
		"prettierd",
		"black",
		"ruff",
		"eslint_d",
		"shellcheck",
		"stylua",
		"prettier",
		"json-lsp",
		"marksman",
	},
})

-- LspAttach keymaps
vim.api.nvim_create_autocmd(
	"LspAttach",
	{ --  Use LspAttach autocommand to only map the following keys after the language server attaches to the current buffer
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc" -- Enable completion triggered by <c-x><c-o>
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
		end,
	}
)

-- Diagnostics
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

map("n", "<space>dw", diagnostic.setqflist, {
	desc = "put window diagnostics to qf",
})

map("n", "<space>db", function()
	set_qflist(0)
end, { desc = "put buffer diagnostics to qf" })

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.focus = true
	opts.anchor_bias = "below"
	opts.max_height = 9
	opts.max_width = 80
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
