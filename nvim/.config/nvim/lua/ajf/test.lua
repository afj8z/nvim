local parent = "/home/aidanfleming/"
local path = "/home/aidanfleming/documents/uni/pygls.log"

local nmap = function(lhs, rhs, opt)
	vim.keymap.set("n", lhs, rhs, opt)
end

local output_p = vim.print(path, "p")

local function get_dirs()
	local par = "/home/aidanfleming/"
	local cur = "/home/aidanfleming/documents/uni/"
	while cur ~= par do
		local pattern1 = "^(.+)/"
		local pattern2 = "^(.+)/(.+)/"

		if string.match(path, pattern1) == nil then
			cur = string.match(path, pattern2)
		else
			cur = string.match(path, pattern1)
		end
	end
end

nmap("<leader>3", get_dirs)
