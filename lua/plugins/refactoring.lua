return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local refactoring = require("refactoring")

		refactoring.setup()

		vim.keymap.set("v", "<leader>rr", function()
			refactoring.select_refactor()
		end, { noremap = true, silent = true })
	end,
}
