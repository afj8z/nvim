local function mfig()
	local cwf = vim.api.nvim_buf_get_name(0)
	local ft = vim.bo.filetype
	if ft ~= "typst" then
		return print("NotATypstFile")
	end
	local root = vim.fs.root(0, cwf)
	local figf = root .. "/in/figs.typ"
	local cmd = vim.uv.fs_stat(figf)
	if cmd == nil then
		return print("IsTypst,ButNoFigFile")
	end
	-- vim.cmd("e " .. figf)
	io.popen("typst compile " .. figf .. " --format svg fig_{p}.typ")

	local metadata = vim.fn.system({
		"typst",
		"query",
		figf,
		"metadata",
	})
	local tojson = vim.json.decode(metadata)
	local fign = tojson[1].value.fig_n + 1
	--
	-- local templates = {
	-- 	typst = {
	-- 		'#snip("' .. snip .. '"),',
	-- 	},
	-- }
	--
	-- local template_string = templates[ftype]
	--
	-- local function insert_lines(template)
	-- 	for i, txt in ipairs(template) do
	-- 		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- 		vim.api.nvim_buf_set_lines(
	-- 			0,
	-- 			row + i - 2,
	-- 			row + i - 1,
	-- 			false,
	-- 			{ txt }
	-- 		)
	-- 	end
	-- end
	--
	-- insert_lines(template_string)
	-- vim.api.nvim_buf_get_name
	return vim.print(fign)
end

vim.api.nvim_create_user_command("Mfig", mfig, {})
