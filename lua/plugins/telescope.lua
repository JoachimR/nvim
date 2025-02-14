return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					path_display = { len = 2 },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
						},
					},
				},
			})

			telescope.load_extension("fzf")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ft", function()
				builtin.colorscheme({ enable_preview = true })
			end, {})
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fw", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>gs", builtin.git_status, {})
			vim.keymap.set("n", "<leader>f<CR>", builtin.resume, {})
			vim.keymap.set("n", "<leader>fo", builtin.oldfiles, {})

			vim.keymap.set("n", "<leader>fk", function()
				require("telescope.builtin").keymaps()
			end, {})

			vim.keymap.set("n", "<leader>gt", function()
				builtin.diagnostics({ bufnr = 0 })
			end, {})

			vim.keymap.set("n", "gr", builtin.lsp_references, {})
			-- -- exclude references starting with `import`
			-- local function custom_lsp_references()
			--   vim.lsp.buf.references({}, function(result)
			--     local filtered_result = {}
			--     for _, item in ipairs(result) do
			--       local line = vim.api.nvim_buf_get_lines(
			--         item.uri,
			--         item.range.start.line,
			--         item.range.start.line + 1,
			--         false
			--       )[1]
			--       if not line:match("^import") then
			--         table.insert(filtered_result, item)
			--       end
			--     end
			--     vim.lsp.util.set_qflist(filtered_result, " ", { title = "LSP References" })
			--     vim.cmd("copen")
			--   end)
			-- end
			-- vim.keymap.set("n", "gr", custom_lsp_references, {})
		end,
	},
}
