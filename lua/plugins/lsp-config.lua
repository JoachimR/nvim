return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"vue_ls",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Helper to find TypeScript lib (supports pnpm monorepos)
			local function get_typescript_lib_path()
				local cwd = vim.fn.getcwd()
				-- Try standard node_modules path first
				local standard_path = cwd .. "/node_modules/typescript/lib"
				if vim.fn.isdirectory(standard_path) == 1 then
					return standard_path
				end
				-- Try pnpm store (glob for versioned typescript)
				local pnpm_glob = cwd .. "/node_modules/.pnpm/typescript@*/node_modules/typescript/lib"
				local pnpm_matches = vim.fn.glob(pnpm_glob, false, true)
				if #pnpm_matches > 0 then
					return pnpm_matches[1]
				end
				-- Fallback to standard path (let LSP handle missing)
				return standard_path
			end

			-- Lua
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
			})

			-- Kotlin
			vim.lsp.config("kotlin_language_server", {
				capabilities = capabilities,
			})

			-- Bash
			vim.lsp.config("bashls", {
				capabilities = capabilities,
			})

			-- Volar for Vue (also handles TypeScript in Vue projects)
			vim.lsp.config("vue_ls", {
				capabilities = capabilities,
				filetypes = { "vue", "typescript", "javascript", "typescriptreact", "javascriptreact" },
				init_options = {
					vue = {
						hybridMode = false,
					},
					typescript = {
						tsdk = get_typescript_lib_path(),
					},
				},
			})

			-- Enable all configured servers
			vim.lsp.enable({ "lua_ls", "kotlin_language_server", "bashls", "vue_ls" })

			-- LSP Keymaps on attach
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
