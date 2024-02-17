return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.diagnostics.eslint_d,
			},

			-- format on save, unless it is vue or ts, then run EslintFixAll
			on_attach = function(client, bufnr)
				local isClientVueOrTs = function()
					local filename = vim.fn.expand("%:t")
					local file_extension = vim.fn.fnamemodify(filename, ":e")
					return file_extension == "vue" or file_extension == "ts"
				end

				local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							if isClientVueOrTs() then
								vim.cmd("EslintFixAll")
							else
								vim.lsp.buf.format()
							end
						end,
					})
				end
			end,
		})

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
