local uf = require("ajf.userfunc")
local add = vim.api.nvim_create_user_command

add("Spon", function()
	uf.toggle_spell_lang(true, "_")
end, {})

add("Spoff", function()
	uf.toggle_spell_lang(false, "_")
end, {})

add("Spde", function()
	uf.toggle_spell_lang(true, "de")
end, {})

add("Spen", function()
	uf.toggle_spell_lang(true, "en")
end, {})

add("SnipList", uf.list_snips, {})

add("Spen", function()
	uf.toggle_spell_lang(true, "en")
end, {})

add("Make", function(opts)
	vim.cmd("silent make " .. opts.args)

	local has_errors = false
	for _, item in ipairs(vim.fn.getqflist()) do
		if item.valid == 1 then
			has_errors = true
			break
		end
	end

	if has_errors then
		require("trouble").open("quickfix")
	else
		require("trouble").close()
		vim.notify(
			"Success: " .. (opts.args == "" and "default target" or opts.args),
			vim.log.levels.INFO,
			{ title = "Make" }
		)
	end
end, {
	nargs = "*",
	desc = "Run builtin :make and send errors to trouble.nvim",
})

add("Lp", function(opts)
	vim.cmd("lua print(" .. opts.args .. ")")
end, { nargs = "*" })

add("Lp", function(opts)
	vim.cmd("lua print(" .. opts.args .. ")")
end, { nargs = "*" })

add("Rld", ":update<CR>:source<CR>", {})
