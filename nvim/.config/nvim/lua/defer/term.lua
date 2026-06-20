-- taken from https://github.com/justinmk/config/blob/master/.config/nvim/lua/my/ctrl_s_shell.lua
-- and rewritten in lua, with slight behaviour change to `'C-t`, with this opening shell in new split
-- in current window

local shell_state = {
	prevwid = vim.api.nvim_get_current_win(),
}

local function make_term(cnt, mode, custom_term_name)
	local term_name = custom_term_name or ":shell"
	shell_state.prevwid = shell_state.prevwid or vim.api.nvim_get_current_win()
	local b = vim.fn.bufnr(term_name)

	-- return to previous window, maybe close the :shell tabpage/split
	if vim.api.nvim_get_current_buf() == b then
		local tab = vim.fn.tabpagenr()
		local term_prevwid = vim.api.nvim_get_current_win()

		if vim.fn.win_gotoid(shell_state.prevwid) == 0 then
			vim.cmd("wincmd p")
		end

		if vim.fn.tabpagewinnr(tab, "$") == 1 and vim.fn.tabpagenr() ~= tab then
			vim.cmd("tabclose " .. tab)
		end

		if vim.api.nvim_get_current_buf() == b then
			-- Edge-case: :shell buffer showing in multiple windows in curtab.
			local bufs = vim.tbl_filter(function(v)
				return v ~= b
			end, vim.fn.tabpagebuflist())
			if #bufs > 0 then
				vim.cmd(vim.fn.bufwinnr(bufs[1]) .. "wincmd w")
			else
				-- last resort: cleanup stale, empty :shell buffer caused by :mksession
				if
					vim.bo.buftype ~= "terminal"
					and vim.fn.getline(1) == ""
					and vim.fn.line("$") == 1
				then
					vim.cmd("bwipeout! %")
					make_term(cnt, mode)
				end
				return
			end
		end
		shell_state.prevwid = term_prevwid
		return
	end

	local split_cmd
	if mode == "tab" then
		split_cmd = cnt > 0 and (cnt .. "split") or "tab split"
	else
		if cnt > 0 then
			split_cmd = cnt .. "split"
		elseif #vim.api.nvim_tabpage_list_wins(0) == 1 then
			split_cmd = "belowright vsplit"
		else
			split_cmd = "belowright split"
		end
	end

	-- Go to existing :shell or create a new one.
	local curwinid = vim.api.nvim_get_current_win()

	if
		cnt == 0
		and vim.fn.bufexists(b) == 1
		and vim.fn.winbufnr(shell_state.prevwid) == b
	then
		-- Go to :shell displayed in the previous window.
		vim.fn.win_gotoid(shell_state.prevwid)
	elseif vim.fn.bufexists(b) == 1 then
		-- Go to existing :shell.
		local w = vim.fn.bufwinid(b)
		if cnt == 0 and w > 0 then
			vim.fn.win_gotoid(w)
		else
			local ws = vim.fn.win_findbuf(b)
			if cnt == 0 and #ws > 0 then
				vim.fn.win_gotoid(ws[1])
			else
				vim.cmd(split_cmd)
				vim.cmd("buffer " .. b)
			end
		end

		if
			vim.bo.buftype ~= "terminal"
			and vim.fn.getline(1) == ""
			and vim.fn.line("$") == 1
		then
			vim.fn.win_gotoid(shell_state.prevwid)
			vim.cmd("bwipeout! " .. b)
			make_term(cnt, mode)
		end
	else
		local origbuf = vim.api.nvim_get_current_buf()

		vim.cmd(split_cmd)
		vim.cmd("terminal")
		vim.bo.scrollback = 100000

		pcall(vim.api.nvim_buf_set_name, 0, term_name)
		pcall(vim.cmd, "bwipeout! #")

		vim.api.nvim_create_autocmd("VimLeavePre", {
			pattern = "*",
			command = "bwipeout! ^" .. term_name .. "$",
		})

		vim.cmd("let @# = " .. origbuf)

		vim.keymap.set("t", "<C-t>", function()
			local termcode =
				vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
			vim.api.nvim_feedkeys(termcode, "n", false)
			vim.schedule(function()
				make_term(0, mode, term_name)
			end)
		end, { buffer = true, silent = true })
	end

	shell_state.prevwid = curwinid
	vim.bo.buflisted = false
end

local function hide_shell()
	local buffers = vim.tbl_filter(function(b)
		return vim.fn.bufname(b):match("^:shell")
	end, vim.api.nvim_list_bufs())

	for _, b in ipairs(buffers) do
		local wins = vim.fn.win_findbuf(b)
		for _, win in ipairs(wins) do
			pcall(vim.api.nvim_win_close, win, true)
		end
	end
end

vim.keymap.set(
	{ "n" },
	"<M-t>",
	hide_shell,
	{ silent = true, desc = "Hide :shell window" }
)

vim.keymap.set("t", "<C-s>", function()
	local termcode =
		vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
	vim.api.nvim_feedkeys(termcode, "n", false)
	vim.schedule(hide_shell)
end, { silent = true, desc = "Hide :shell window from terminal" })

vim.keymap.set("n", "<C-s>", function()
	make_term(vim.v.count, "tab")
end, { silent = true, desc = "Toggle :shell in new tab" })
vim.keymap.set("n", "<C-S-S>", function()
	make_term(vim.v.count, "split")
end, { silent = true, desc = "Toggle :shell in split" })
vim.keymap.set("n", "%<C-s>", function()
	local current_file = vim.fn.expand("%:t")
	local term_name = current_file ~= "" and (":shell_" .. current_file)
		or ":shell_unnamed"
	make_term(vim.v.count, "split", term_name)
end, { silent = true, desc = "Toggle file-specific :shell in split" })
