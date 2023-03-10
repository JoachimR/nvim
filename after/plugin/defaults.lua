vim.g.mapleader = " "

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = false

vim.wo.relativenumber = true

vim.keymap.set('i', 'jj', '<Esc>', { noremap = true })
vim.keymap.set('i', 'kk', '<Esc>', { noremap = true })
vim.keymap.set('i', 'bb', '<Esc>', { noremap = true })



vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })


-- save file
vim.keymap.set('n', '<leader>ww', ":w<CR>", { desc = 'Save file' })

-- nvim-tree
-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup()

vim.keymap.set("n","<leader>1", ":NvimTreeToggle<CR>")

-- format on save
require('lspconfig').eslint.setup({
  on_attach = function(_, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})
