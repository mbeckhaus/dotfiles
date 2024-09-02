return {
    'ggandor/leap.nvim',
    config = function(_, opts)
        require('leap').setup({
            safe_labels = {}
        })
        vim.keymap.set('n', 's', function()
            require('leap').leap { target_windows = { vim.api.nvim_get_current_win() } }
        end)
        vim.api.nvim_create_autocmd(
            "User",
            {
                callback = function()
                    vim.cmd.hi("Cursor", "blend=100")
                    vim.opt.guicursor:append { "a:Cursor/lCursor" }
                end,
                pattern = "LeapEnter"
            }
        )
        vim.api.nvim_create_autocmd(
            "User",
            {
                callback = function()
                    vim.cmd.hi("Cursor", "blend=0")
                    vim.opt.guicursor:remove { "a:Cursor/lCursor" }
                end,
                pattern = "LeapLeave"
            }
        )
    end,
}
