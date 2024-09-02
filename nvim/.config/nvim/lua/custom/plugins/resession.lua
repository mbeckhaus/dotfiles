-- Resession does NOTHING automagically, so we have to set up some keymaps
return {
  'stevearc/resession.nvim',
  config = function()
    require('resession').setup()
    -- vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set("n", "<leader>rs", require 'resession'.save, { desc = '[R]esession [S]ave ' })
    vim.keymap.set("n", "<leader>rl", require 'resession'.load, { desc = '[R]esession [L]oad' })
    vim.keymap.set("n", "<leader>rd", require 'resession'.delete, { desc = '[R]esession [D]elete' })
  end,
}
