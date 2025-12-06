local uf = require("ajf.userfunc")

vim.api.nvim_create_user_command("Spon", function()
	uf.toggle_spell_lang(true, "_")
end, {})

vim.api.nvim_create_user_command("Spoff", function()
	uf.toggle_spell_lang(false, "_")
end, {})

vim.api.nvim_create_user_command("Spde", function()
	uf.toggle_spell_lang(true, "de")
end, {})

vim.api.nvim_create_user_command("Spen", function()
	uf.toggle_spell_lang(true, "en")
end, {})

vim.api.nvim_create_user_command("SnipList", uf.list_snips, {})

vim.api.nvim_create_user_command("Spen", function()
	uf.toggle_spell_lang(true, "en")
end, {})

local function lua_runner()
	local cwd = vim.fn.getcwd(0)
	local fpath = vim.api.nvim_buf_get_name(0)
	local ft = vim.bo.filetype

	local fwd = vim.fn.fnamemodify(fpath, ":p:h")
	print(cwd, fpath, ft, fwd)
end

vim.api.nvim_create_user_command("LUA", function()
	lua_runner()
end, {})
