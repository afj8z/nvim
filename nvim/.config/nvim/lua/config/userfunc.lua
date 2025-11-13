local map = vim.keymap.set

function RUN_FILE()
	local fpath = vim.api.nvim_buf_get_name(0)
	if fpath == "" then
		vim.notify("No file to run", vim.log.levels.WARN)
		return
	end
	local ftype = vim.bo.filetype
	local map = {
		python = function()
			return { "python3", fpath }
		end,
		lua = function()
			return { "lua", fpath }
		end,
		javascript = function()
			return { "node", fpath }
		end,
		typescript = function()
			if vim.fn.executable("tsx") == 1 then
				return { "tsx", fpath }
			end
			if vim.fn.executable("ts-node") == 1 then
				return { "ts-node", fpath }
			end
			if vim.fn.executable("deno") == 1 then
				return { "deno", "run", fpath }
			end
		end,
		sh = function()
			return { "bash", fpath }
		end,
		bash = function()
			return { "bash", fpath }
		end,
		zsh = function()
			return { "zsh", fpath }
		end,
		ruby = function()
			return { "ruby", fpath }
		end,
		perl = function()
			return { "perl", fpath }
		end,
		php = function()
			return { "php", fpath }
		end,
		r = function()
			return { "Rscript", fpath }
		end,
		julia = function()
			return { "julia", fpath }
		end,
		go = function()
			return { "go", "run", fpath }
		end,
	}
	local ft = map[ftype]

	local cmd = ft and ft() or (vim.fn.executable(fpath) == 1 and { fpath } or nil)
	-- vim.api.nvim_command('split')
	-- vim.api.nvim_command('terminal')
	-- vim.api.nvim_paste(ftype .. " " .. fpath, false, -1)

	local curwin = vim.api.nvim_get_current_win()
	local target = math.max(3, math.floor(vim.api.nvim_win_get_height(curwin) * 0.25))
	local was_equalalways = vim.o.equalalways
	vim.o.equalalways = false
	vim.cmd(("belowright %dsplit"):format(target))

	vim.cmd("enew")
	local termbuf = vim.api.nvim_get_current_buf()
	vim.bo[termbuf].bufhidden = "wipe"
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.signcolumn = "no"
	pcall(vim.diagnostic.disable, termbuf)

	local cwd = vim.fn.fnamemodify(fpath, ":p:h")
	-- jobstart()| with `{term: v:true}`
	vim.fn.termopen(cmd, { cwd = cwd })
	vim.cmd("startinsert")

	vim.cmd("wincmd p")
	vim.o.equalalways = was_equalalways
end

map("n", "<Leader>m", "<cmd>lua RUN_FILE()<CR>")

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
