return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "tsserver" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.eslint.setup({
				capabilities = capabilities,
				filetypes = { "typescript", "vue", "javascript" },
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.cmd("EslintFixAll")
						end,
					})
					-- local filename = vim.fn.expand("%:t")
					-- local file_extension = vim.fn.fnamemodify(filename, ":e")
					-- if file_extension == "vue" or file_extension == "ts" then
					--   vim.api.nvim_create_autocmd("BufWritePre", {
					--     buffer = bufnr,
					--     callback = function()
					--       vim.cmd("EslintFixAll")
					--     end,
					--   })
					-- end
				end,
			})
			lspconfig.tsserver.setup({
				capabilities = capabilities,
				filetypes = { "typescript" },
			})
			lspconfig.volar.setup({
				capabilities = capabilities,
				filetypes = { "vue" },
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					local opts = { buffer = ev.buf }

					vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<space>lr", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<space>la", vim.lsp.buf.code_action, opts)
				end,
			})
		end,
	},
}
