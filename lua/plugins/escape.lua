return {
	"max397574/better-escape.nvim",
	event = "VeryLazy",
	config = function()
		require("better_escape").setup({
			timeout = vim.o.timeoutlen, -- after `timeout` passes, you can press the escape key and the plugin will ignore it
			default_mappings = false,
			mappings = {
				i = {
					k = {
						k = "<Esc>",
					},
					j = {
						j = "<Esc>",
					},
					b = {
						b = "<Esc>",
					},
				},
			},
		})
	end,
}
