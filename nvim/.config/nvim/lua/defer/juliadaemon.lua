local julia_daemon_id = nil
local daemon_port = "3001"

local group = vim.api.nvim_create_augroup("JuliaPlotEnvironment", { clear = true })

-- vim.lsp.enable("julials")

-- TODO: current: spin up daemon on any julia file; maybe conditionally for plots?
vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	pattern = "*.jl",
	callback = function()
		if not julia_daemon_id then
			vim.notify(
				"Starting Julia Daemon (Wait for Ready signal)...",
				vim.log.levels.INFO
			)

			julia_daemon_id = vim.fn.jobstart({
				"julia",
				"--startup-file=no",
				"-t",
				"auto",
				"-e",
				-- debug
				string.format(
					'using Revise; using DaemonMode; println("DAEMON_READY"); serve(%s)',
					daemon_port
				),
			}, {
				on_stdout = function(_, data)
					if data then
						for _, line in ipairs(data) do
							if line == "DAEMON_READY" then
								vim.schedule(function()
									vim.notify(
										"Julia Daemon is Ready!",
										vim.log.levels.INFO
									)
								end)
							end
						end
					end
				end,
				on_stderr = function(_, data)
					-- catch silent crashes
					if data and #data > 0 and data[1] ~= "" then
						vim.schedule(function()
							vim.api.nvim_echo({
								{
									"Daemon Error: " .. table.concat(data, "\n"),
									"ErrorMsg",
								},
							}, true, {})
						end)
					end
				end,
			})
		end
	end,
})

-- async exec on save in dir
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	pattern = "*.jl",
	callback = function()
		local filepath = vim.api.nvim_buf_get_name(0)
		local file_dir = vim.fs.dirname(filepath)

		vim.fn.jobstart({
			"julia",
			"--startup-file=no",
			"-e",
			string.format("using DaemonMode; runargs(%s)", daemon_port),
			filepath,
		}, {
			cwd = file_dir, -- script root
			on_stderr = function(_, data)
				if data and #data > 1 then
					vim.schedule(function()
						vim.api.nvim_echo(
							{ { table.concat(data, "\n"), "ErrorMsg" } },
							true,
							{}
						)
					end)
				end
			end,
		})
	end,
})

vim.api.nvim_create_autocmd("VimLeave", {
	group = group,
	callback = function()
		if julia_daemon_id then
			vim.fn.jobstop(julia_daemon_id)
			julia_daemon_id = nil
		end
	end,
})
