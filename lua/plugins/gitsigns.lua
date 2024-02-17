return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup()
		vim.keymap.set("n", "<C-n>", ":Gitsigns next_hunk<CR>", { noremap = true })
		vim.keymap.set("n", "<C-j>", ":Gitsigns prev_hunk<CR>", { noremap = true })
	end,
}
