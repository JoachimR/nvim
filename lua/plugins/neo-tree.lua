return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true })

		-- open neotree and focus on file of current buffer
		vim.keymap.set("n", "<leader>tt", ":Neotree reveal<CR>", { noremap = true })

    local neotree = require("neo-tree")
    neotree.setup({
      close_if_last_window = true,
      popup_border_style = "rounded",
      filesystem = {
        filtered_items = {
          hide_by_name = {
            "node_modules"
          },
        },
      },
    })
	end,
}
