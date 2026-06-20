local function load_skeletal()
	require("skeletal").setup({
		template_dir = vim.fn.expand("~/documents/templates"),
		jump_mapping = "<leader>j",
		picker = "snacks",
		values = {
			author = function()
				return vim.env.USER
			end,
		},
		rules = {
			{
				name = "Daily note",
				match = {
					filetype = "markdown",
					dir = "notes/journal",
				},
				template = "daily.md",
				values = {
					title = function(ctx)
						return ctx.basename
					end,
				},
			},
			{
				name = "University Note System",
				match = {
					dir = "notes/uni/**",
					extension = "typ",
				},
				exclude = {
					dir = { "assets", "data", "dict" },
				},

				template = function(ctx)
					local f = ctx.filename
					local n = ctx.basename

					if f:match("^lec_") then
						return "lecture.typ"
					end

					if f:match("^hw_") or f:match("^abg_") then
						return "assignment.typ"
					end

					local par = vim.fs.dirname(ctx.path)
					local gpar = vim.fs.basename(vim.fs.dirname(par))
					if gpar == "uni" and n == "org" then
						return "org.typ"
					end

					if ctx.parent_dir == "code" and n == n:upper() then
						return "doc.typ"
					end

					return "note.typ"
				end,

				values = {
					course = function(ctx)
						local map = {
							progii = "Programmieren II",
							stai = "Grundlagen Statistik",
							emwi = "Empirische Wirtschaftswissenschaft",
							fiwi = "Finanzwissenschaft",
							spth = "Spieltheorie",
							wipo = "Wirtschaftspolitik",
						}
						return map[ctx.parent_dir] or ctx.parent_dir:upper()
					end,
					number = function(ctx)
						return ctx.basename:match("_(%d+)") or "00"
					end,

					category = function(ctx)
						local cat = ctx.basename:match("^(%w+)_")
						local labels = {
							lec = "Vorlesung",
							exam = "Klausur",
							hw = "Abgabe",
							abg = "Abgabe",
							org = "Organisatorisch",
						}
						return labels[cat] or "Note"
					end,
					title = function(ctx)
						local t = ctx.basename:match("%d+_(.+)$") or ctx.basename
						return t:gsub("-", " "):gsub("(%a)([%w]*)", function(f, r)
							return f:upper() .. r:lower()
						end)
					end,
				},
			},
		},
	})
end

return {
	name = "skeletal",
	load = load_skeletal,
	deps = "snacks",
}
