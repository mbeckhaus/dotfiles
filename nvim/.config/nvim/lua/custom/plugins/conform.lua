return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	opts = {},
	config = function()
		require("conform").setup({
			timeout_ms = 500,
			lsp_format = "fallback",
			formatters_by_ft = {
				json = { "jq" },
				lua = { "stylua" },
				java = { "intellij_format" },
			},

			formatters = {
				intellij_format = {
					command = "format.sh",
					args = function()
						return {
							"-allowDefaults", -- Add your script's required arguments
							vim.api.nvim_buf_get_name(0), -- Get the current buffer's file path
						}
					end,
					stdin = false,
				},
			},
		})
	end,
	vim.keymap.set("", "<leader>f", function()
		require("conform").format({
			async = true , lsp_fallback = true,
		})
	end, { desc = "[F]ormat" }),
}
