local function list_snips()
	local filetype = vim.bo.filetype
	local available_snippets = require("luasnip").available()

	if not available_snippets[filetype] then
		print("No LuaSnip snippets found for filetype: " .. filetype)
		return
	end

	local snips_info = {}
	for _, snippet in ipairs(available_snippets[filetype]) do
		table.insert(snips_info, {
			trigger = snippet.trigger,
			name = snippet.name or "N/A",
			type = snippet.snippetType or "snippet",
		})
	end

	if #snips_info == 0 then
		print("No LuaSnip snippets found for filetype: " .. filetype)
		return
	end

	print("Available snippets for filetype: " .. filetype)
	for _, info in ipairs(snips_info) do
		print(string.format("- Trigger: %-15s Name: %-30s Type: %s", info.trigger, info.name, info.type))
	end
end
vim.api.nvim_create_user_command("SnipList", list_snips, {})

---@param toggle_on boolean
---@param lang string
local function toggle_spell_lang(toggle_on, lang)
	if toggle_on == nil or "" then
		toggle_on = true
	end
	if lang ~= "_" then
		vim.cmd("lua vim.o.spell=true")
		vim.cmd("lua vim.o.spelllang='" .. lang .. "'")
		vim.cmd("se spelllang?")
		return
	else
		if lang == "_" then
			local enabled = vim.o.spell
			if toggle_on == true and enabled == false then
				vim.cmd("lua vim.o.spell=true")
				vim.cmd("se spell?")
				return
			else
				if toggle_on == false and enabled == true then
					vim.cmd("lua vim.o.spell=false")
					vim.cmd("se spell?")
				else
					return vim.cmd("se spell?")
				end
			end
		end
	end
end

vim.api.nvim_create_user_command("Spon", function()
	toggle_spell_lang(true, "_")
end, {})

vim.api.nvim_create_user_command("Spoff", function()
	toggle_spell_lang(false, "_")
end, {})

vim.api.nvim_create_user_command("Spde", function()
	toggle_spell_lang(true, "de")
end, {})

vim.api.nvim_create_user_command("Spen", function()
	toggle_spell_lang(true, "en")
end, {})
