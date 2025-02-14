return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
			},

			-- format on save, unless it is vue or ts, then run EslintFixAll
			on_attach = function(client, bufnr)
				local function debug_print(message)
					if type(message) == "boolean" then
						message = tostring(message) -- Convert boolean to string
					end
					vim.api.nvim_out_write("[DEBUG] " .. message .. "\n")
				end
				local endsWith = function(str, suffix)
					return string.sub(str, -string.len(suffix)) == suffix
				end
				local isClientTs = function()
					local filename = vim.fn.expand("%:t")
					local isTs = endsWith(filename, ".ts")
					return isTs
				end

				-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
				-- if client.supports_method("textDocument/formatting") then
				-- 	vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				-- 	vim.api.nvim_create_autocmd("BufWritePre", {
				-- 		group = augroup,
				-- 		buffer = bufnr,
				-- 		callback = function()
				-- 			-- if isClientTs() then
				-- 			vim.cmd("EslintFixAll")
				-- 			-- else
				-- 			-- vim.lsp.buf.format()
				-- 			-- end
				-- 		end,
				-- 	})
				-- end
			end,
		})
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

		local function eslint_fix_and_write()
			vim.cmd("EslintFixAll")
			vim.cmd("write")
		end
		vim.keymap.set("n", "<leader>ww", eslint_fix_and_write, {})
	end,
}
