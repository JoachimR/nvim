return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
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
			vim.keymap.set("n", "gr", builtin.lsp_references, {})

			vim.keymap.set("n", "<leader>fk", function()
				require("telescope.builtin").keymaps()
			end, {})

			vim.keymap.set("n", "<leader>gt", function()
				builtin.diagnostics({ bufnr = 0 })
			end, {})
		end,
	},
}
