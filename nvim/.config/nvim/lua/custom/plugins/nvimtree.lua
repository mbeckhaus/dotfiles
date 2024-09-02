function ResizeTree()
    local percentage = 25
    local ratio = percentage / 100
    local width = math.floor(vim.go.columns * ratio)
    vim.cmd("NvimTreeResize " .. width)
end

local resized_tree_group = vim.api.nvim_create_augroup('VimResizedTreeGroup', { clear = true })
vim.api.nvim_create_autocmd('VimResized', {
    callback = function()
        ResizeTree()
    end,
    group = resized_tree_group,
    pattern = '*',
})

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        -- Count listed buffers that are not NvimTree
        local buffer_count = 0
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
                local bufname = vim.api.nvim_buf_get_name(buf)
                if not string.find(bufname, "NvimTree_") then
                    buffer_count = buffer_count + 1
                end
            end
        end

        -- If this is the first real buffer besides NvimTree
        if buffer_count == 1 then
            ResizeTree()
        end
    end
})

return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local nvimtree = require('nvim-tree')
        nvimtree.setup {
            actions = {
                open_file = {
                    resize_window = false
                }
            },
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                width = "30%",
            },
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = true,
            },
        }
        vim.keymap.set("n", "<leader>tr", ':NvimTreeToggle<CR>', { desc = '[T][R]ee' })
        vim.keymap.set("n", "<leader>rt", function() ResizeTree() end, { desc = '[R]esize [T]ree' })
        vim.keymap.set("n", "<leader>nff", ":NvimTreeFindFile<CR>", { desc = '[N]vim Tree [F]ind [F]ile' })
        vim.keymap.set("n", "<leader>to", ':NvimTreeFindFile<CR>',
            { desc = '[T]ree [O]pen (Open the file in the nvim tree)' })
    end,
}
