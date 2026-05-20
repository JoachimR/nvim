return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
			},
		})

		-- Format with LSP (uses prettier for non-eslint files like lua)
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
