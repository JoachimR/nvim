return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {},
  config = function()
    require("typescript-tools").setup {}

    vim.keymap.set("n", "<leader>i", "<cmd>:TSToolsAddMissingImports<CR>", { noremap = true })
  end,
}
