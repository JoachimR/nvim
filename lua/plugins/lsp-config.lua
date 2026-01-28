return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function(on_attach)
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
			})
			vim.lsp.config("kotlin_language_server", {})
			vim.lsp.config("bashls", {
				capabilities = capabilities,
			})

      vim.lsp.config('eslint', {
        capabilities = capabilities,
        filetypes = { "vue", "typescript", "javascript" },
        on_attach = function(_, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
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

			vim.g.diagnostics_active = false
			local function toggle_diagnostics()
				if vim.g.diagnostics_active then
					vim.g.diagnostics_active = false
					vim.lsp.diagnostic.clear(0)
					vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
				else
					vim.g.diagnostics_active = true
					vim.lsp.handlers["textDocument/publishDiagnostics"] =
						vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
							virtual_text = true,
							signs = true,
							underline = true,
							update_in_insert = false,
						})
				end
			end

			vim.keymap.set("n", "<leader>dia", toggle_diagnostics, { noremap = true, silent = true })
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		-- config = function()
		-- 	require("mason-lspconfig").setup({
		-- 		ensure_installed = { "lua_ls" },
		-- 	})
		-- end,
	},
}
