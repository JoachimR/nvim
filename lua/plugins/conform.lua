return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		local conform = require("conform")

		local js_ts_filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
		}

		local prettier_filetypes = {
			"vue",
			"json",
			"jsonc",
			"css",
			"scss",
			"html",
			"markdown",
			"yaml",
		}

		local formatters_by_ft = {
			lua = { "stylua" },
		}
		for _, ft in ipairs(js_ts_filetypes) do
			formatters_by_ft[ft] = { "oxlint_fix", "oxfmt" }
		end
		for _, ft in ipairs(prettier_filetypes) do
			formatters_by_ft[ft] = { "prettier" }
		end

		conform.setup({
			formatters_by_ft = formatters_by_ft,
			formatters = {
				oxlint_fix = {
					command = "oxlint",
					args = { "--fix", "$FILENAME" },
					stdin = false,
					cwd = require("conform.util").root_file({ "package.json", ".git" }),
				},
				oxfmt = {
					command = "oxfmt",
					stdin = true,
					cwd = require("conform.util").root_file({ "package.json", ".git" }),
				},
			},
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { timeout_ms = 2000, lsp_fallback = true }
			end,
		})

		-- Prefer project-local oxc binaries when present
		local function prepend_local_bin(formatter_name, bin_name)
			local cwd = vim.fn.getcwd()
			local local_bin = cwd .. "/node_modules/.bin/" .. bin_name
			if vim.fn.executable(local_bin) == 1 then
				conform.formatters[formatter_name] = vim.tbl_extend("force", conform.formatters[formatter_name] or {}, {
					command = local_bin,
				})
			end
		end
		prepend_local_bin("oxlint_fix", "oxlint")
		prepend_local_bin("oxfmt", "oxfmt")

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save (use ! for buffer-local)",
			bang = true,
		})

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})

		vim.keymap.set({ "n", "v" }, "<leader>gf", function()
			conform.format({ async = false, lsp_fallback = true })
		end, { desc = "Format buffer" })
	end,
}
