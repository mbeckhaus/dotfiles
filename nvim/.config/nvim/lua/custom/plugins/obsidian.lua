function new_note_with_date_prefix()
    local date_prefix = os.date("%Y-%m-%d")
    vim.ui.input({ prompt = date_prefix .. '-Titel: ' }, function(title)
        if title then
            local full_title = date_prefix .. "-" .. title
            vim.cmd('ObsidianNew ' .. full_title)
            vim.api.nvim_put({ '' }, 'l', true, true)
            vim.cmd('startinsert')
        end
    end)
end

function new_note()
    vim.ui.input({ prompt = 'Titel: ' }, function(title)
        if title then
            vim.cmd('ObsidianNew ' .. title)
        else
            vim.cmd('ObsidianNew  ')
        end
        vim.api.nvim_put({''},'l',true,true)
        vim.cmd('startinsert')
    end)
end

return {
    'epwalsh/obsidian.nvim',

    event = "VeryLazy",
    config = function()
        require("obsidian").setup({
            workspaces = {
                {
                    name = "Zettelkasten Work",
                    path = "~/Projekte/allianz/Knowledge/Zettelkasten",
                },
                {
                    name = "Zettelkasten Private",
                    path = "~/Projekte/personal/Knowledge/Zettelkasten"
                }
            },

            notes_subdir = "1 Fleeting Notes/",
            new_notes_location = "notes_subdir",

            ui = { enable = false },
            -- No default yaml-template should be inserted at saving:
            disable_frontmatter = true,
            completion = {
                nvim_cmp = true,
                min_chars = 2
            },
            picker = {
                name = "telescope.nvim"
            },

            note_id_func = function(title)
                local suffix = title or ""
                if suffix == "" then
                    for _ = 1, 4 do
                        suffix = suffix .. string.char(math.random(65, 90))
                    end
                    suffix = tostring(os.date("%Y-%m-%d")) .. "-" .. suffix
                end
                --return tostring(os.date("%Y-%m-%d")) .. "-" .. suffix
                return suffix
            end,

            -- function for `:ObsidianFollowLink`
            follow_url_func = function(url)
                -- Open the URL in the default web browser.
                vim.fn.jobstart({ "open", url }) -- Mac OS
                -- vim.fn.jobstart({"xdg-open", url})  -- linux
            end

        })

    end,


    vim.api.nvim_set_keymap(
        'n',
        '<leader>nn',
        ':lua new_note()<CR>',
        { noremap = true, silent = true, desc = '[N]ote [N]ew' }
    ),

    vim.api.nvim_set_keymap(
        'n',
        '<leader>nd',
        ':lua new_note_with_date_prefix()<CR>',
        { noremap = true, silent = true, desc = '[N]ote [D]ate' }
    ),

    vim.api.nvim_set_keymap('n', '<leader>nws', ':ObsidianWorkspace<CR>',
        { noremap = true, silent = true, desc = '[N]ote [W]orkspace [S]witch' }),
    vim.api.nvim_set_keymap('n', '<leader>ng', ':ObsidianSearch<CR>',
        { noremap = true, silent = true, desc = '[N]ote [G]rep' }),
    vim.api.nvim_set_keymap('n', '<leader>ns', ':ObsidianQuickSwitch<CR>',
        { noremap = true, silent = true, desc = '[N]ote [S]earch' }),
}
