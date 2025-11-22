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
