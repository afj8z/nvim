local function load_skeletal()
	require("skeletal").setup({
		template_dir = vim.fn.expand("~/documents/templates"),
		jump_mapping = "<leader>j",
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
					parent_dir = "notes",
				},
				template = "daily.md",
				values = {
					title = function(ctx)
						return ctx.basename
					end,
				},
			},
			{
				name = "Project note",
				match = {
					filetype = "markdown",
					root_dir = "projects",
				},
				template = "project.md",
			},
		},
	})
end

return {
	name = "skeletal",
	load = load_skeletal,
}
