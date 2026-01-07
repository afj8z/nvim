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
	"joker",
}

utils.lazy_on_filetype("LSP", lsp_filetypes, function(args)
	-- node not in sys PATH, so make available to Mason in nvim
	local node_bin_path =
		vim.fn.expand("$HOME/.config/nvm/versions/node/v24.12.0/bin") -- Update version if needed
	if vim.fn.isdirectory(node_bin_path) == 1 then
		vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH
	end
	vim.pack.add({
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/mason-org/mason.nvim" },
		{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
		{
			src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
		},
	})

	require("mason").setup()

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
		end,
	})

	-- This will trigger the actual server setups
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
			"ts_ls",
		},
	})
	vim.schedule(function()
		-- specific check to ensure buffer is still valid and needs this
		if args.buf and vim.api.nvim_buf_is_valid(args.buf) then
			vim.api.nvim_exec_autocmds(
				"FileType",
				{ buffer = args.buf, modeline = false }
			)
		end
	end)
end)

-- Diagnostics config can stay global, i guess startup would be
-- cleaner if kept inside the callback
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
