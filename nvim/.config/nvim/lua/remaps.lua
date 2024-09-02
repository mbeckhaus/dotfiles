-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set("i", "jk", "<Esc>l")

-- move selected lines up and down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join lines and keep cursor position
vim.keymap.set("n", "J", "mzJ`z")

-- keep cursor in center when scrolling up and down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")


-- search next occurance, center the result and search in foldings
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- replace
vim.keymap.set('n', "<Leader>re", [[:%s/<C-r><C-w>//g<Left><Left>]])
vim.keymap.set('v', "<Leader>re", [[:s///g<Left><Left>]])

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set('n', '<leader>p', '"0p', { desc = 'Paste from 0 register' })

-- Remap terminal exit to leader escape
vim.keymap.set('t', 'jk', [[<C-\><C-n>]], { noremap = true, silent = true })
vim.keymap.set('n', '<leader>wr', ':w<CR>', { noremap = true, silent = true })

-- Remove current highlighting 
vim.keymap.set('n', '<leader>nh', ':noh<CR>', { noremap = true, silent = true })
