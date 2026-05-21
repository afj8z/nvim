-- 'tabline'
_G._mytablabel = function(n)
	local buflist = vim.fn.tabpagebuflist(n)
	local winnr = vim.fn.tabpagewinnr(n)
	local tabdir = vim.fn.getcwd(-1, n)
	local has_tabdir = vim.fn.getcwd(-1, -1) ~= tabdir
	if has_tabdir then
		return ("CWD: %s/"):format(vim.fn.fnamemodify(tabdir, ":t"))
	end
	local bufname = vim.fn.bufname(buflist[winnr])
	local isdir = bufname:sub(#bufname) == "/"
	local name = vim.fn.fnamemodify(bufname, isdir and ":h:t" or ":t")
		.. (isdir and "/" or "")
	name = name:len() > 20 and name:sub(1, 20) .. "…" or name
	return name == "" and "No Name" or " " .. name
end
_G._mytabline = function()
	local s = ""
	for i = 1, vim.fn.tabpagenr("$") do
		-- Highlight group.
		local hlgroup = (
			i == vim.fn.tabpagenr() and "%#TabLineSel#" or "%#TabLine#"
		)
		-- %T: set the tabpage number (for mouse clicks).
		s = s .. ("%s%%%dT %%{v:lua._mytablabel(%d)} "):format(hlgroup, i, i)
	end
	-- After last tab: Fill with TabLineFill. Reset tabpage nr. Right-align the "close" (X) button.
	return s .. "%#TabLineFill#%T%=%#TabLine#%999XX"
end

vim.go.tabline = "%!v:lua._mytabline()"
