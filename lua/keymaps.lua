-- basic stuff
vim.g.mapleader = " "

-- navigate horizontal windows with control
vim.keymap.set("n", "<C-h>", "<C-W>h", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-W>l", { noremap = true })

-- go through issues
vim.keymap.set("n", "<C-m>", vim.diagnostic.goto_next, { noremap = true })
vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_prev, { noremap = true })

-- hightlight visual selection
vim.keymap.set("n", "VV", "V$%", { noremap = true })

-- paste and replace without losing yanked text
vim.keymap.set("v", "p", '"_dP', { noremap = true })

vim.keymap.set("n", "<C-q>", ":qa<CR>", { noremap = true })

vim.keymap.set("n", "<S-l>", ":bnext<CR>", { noremap = true })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { noremap = true })

vim.keymap.set("n", "n", "nzz", { noremap = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true })

vim.keymap.set("n", "|", "<cmd>vsplit<cr>", { noremap = true })

vim.keymap.set("n", "<leader>pp", '<cmd>TermExec direction=vertical go_back=0 size=80 cmd=""<cr>', { noremap = true })
