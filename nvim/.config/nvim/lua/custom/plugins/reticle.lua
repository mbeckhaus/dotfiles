return {
    'tummetott/reticle.nvim',
    config = function()
        require('reticle').setup {
            on_startup = {
                cursorline = false,
                cursorcolumn = false,
            },
        }
    end,
    vim.keymap.set('n', '<leader>cf', ':ReticleToggleCursorline<CR>', { desc = '[C]ursor [f]ind' }),
}
