return {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    config = function()
        require("aerial").setup({
            layout = {
                max_width = { 40, 0.2 },
                width = nil,
                min_width = { 40, 0.2 },
            }
        })
        vim.keymap.set("n", "<leader>ae", "<cmd>AerialToggle!<CR>")
    end,
    -- You probably also want to set a keymap to toggle aerial
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
}
