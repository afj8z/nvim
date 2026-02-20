local M = {}

-- Helper to escape pattern for Vim regex
local function escape_pattern(text)
	return text:gsub("([/])", "\\%1")
end

-- Helper to get visual selection
local function get_visual_selection()
	local save_reg = vim.fn.getreg('"')
	local save_regtype = vim.fn.getregtype('"')

	vim.cmd('noau normal! "vy')
	local selection = vim.fn.getreg("v")

	vim.fn.setreg('"', save_reg, save_regtype)
	return selection
end

M.run = function()
	local mode = vim.fn.mode()
	local default_pattern = ""

	-- 1. capture text based on mode
	if mode == "v" or mode == "V" or mode == "\22" then
		default_pattern = get_visual_selection()
		-- FIX: Exit visual mode synchronously to avoid closing the subsequent UI input
		vim.cmd("normal! \27")
	else
		default_pattern = vim.fn.expand("<cword>")
	end

	-- 2. Input: Confirm or Edit Search Pattern (The "Change" you requested)
	vim.ui.input(
		{ prompt = "Search Pattern: ", default = default_pattern },
		function(target)
			if not target or target == "" then
				return
			end -- Cancelled or empty

			-- 3. Input: Replacement Word
			vim.ui.input(
				{ prompt = "Replace '" .. target .. "' with: " },
				function(replacement)
					if not replacement then
						return
					end -- Cancelled

					-- 4. Input: Location
					vim.ui.input(
						{ prompt = "Location (glob): ", default = "**/*" },
						function(location)
							if not location then
								return
							end -- Cancelled

							local esc_target = escape_pattern(target)
							local esc_replacement = escape_pattern(replacement)

							-- Execute Pipeline
							local success, _ = pcall(function()
								vim.cmd(
									"vimgrep /"
										.. esc_target
										.. "/g "
										.. location
								)
							end)

							if not success then
								vim.notify(
									"vimgrep: No matches found for " .. target,
									vim.log.levels.WARN
								)
								return
							end

							vim.cmd("copen")

							-- Execute replacement
							local cmd = string.format(
								"cfdo %%s/%s/%s/gi | update",
								esc_target,
								esc_replacement
							)
							local replace_success, replace_err =
								pcall(vim.cmd, cmd)

							if replace_success then
								vim.notify(
									"Replaced '"
										.. target
										.. "' with '"
										.. replacement
										.. "' in "
										.. location,
									vim.log.levels.INFO
								)
							else
								vim.notify(
									"Error during replacement: " .. replace_err,
									vim.log.levels.ERROR
								)
							end
						end
					)
				end
			)
		end
	)
end

return M
