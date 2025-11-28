local M = {}

local caps = vim.lsp.protocol.make_client_capabilities()

M.caps = caps

-- Try to extend with blink capabilities if available
do
	local ok, blink = pcall(require, "blink.cmp")
	if ok and blink.get_lsp_capabilities then
		M.caps = blink.get_lsp_capabilities(caps)
	end
end

-- Prefer a single position encoding for all servers
M.caps.general = M.caps.general or {}
M.caps.general.positionEncodings = { "utf-16", "utf-8" } -- prefer utf-16
M.caps.offsetEncoding = { "utf-16" } -- backwards-compat for servers using this key

return M
