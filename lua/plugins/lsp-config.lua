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
					"vtsls",
				},
				-- mason-lspconfig auto-enables every installed server. ts_ls is
				-- still installed from before, but it has no Vue plugin and would
				-- attach alongside vtsls, fighting over TypeScript and breaking
				-- .vue references. Exclude it so only vtsls serves TS.
				automatic_enable = {
					exclude = { "ts_ls" },
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

			-- Vue 3 / Volar v2 hybrid mode: vue_ls handles .vue templates, and
			-- delegates all TypeScript (in .ts AND .vue <script> blocks) to vtsls,
			-- which loads @vue/typescript-plugin. This is what makes references
			-- cross .ts <-> .vue boundaries (e.g. gr on an exported symbol finds
			-- its usages inside .vue files).
			local vue_plugin_path = vim.fn.stdpath("data")
				.. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin"

			vim.lsp.config("vue_ls", {
				capabilities = capabilities,
				init_options = {
					typescript = {
						tsdk = get_typescript_lib_path(),
					},
				},
			})

			vim.lsp.config("vtsls", {
				capabilities = capabilities,
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"vue",
				},
				settings = {
					vtsls = {
						tsserver = {
							globalPlugins = {
								{
									name = "@vue/typescript-plugin",
									location = vue_plugin_path,
									languages = { "vue" },
									configNamespace = "typescript",
									enableForWorkspaceTypeScriptVersions = true,
								},
							},
						},
					},
				},
			})

			-- Enable all configured servers
			vim.lsp.enable({ "lua_ls", "kotlin_language_server", "bashls", "vue_ls", "vtsls" })

			-- LSP Keymaps on attach
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					local opts = { buffer = ev.buf }

					vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					-- gd: see telescope.lua (uses lsp_definitions picker)
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
