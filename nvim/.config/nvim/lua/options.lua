-- Set highlight on search
vim.opt.hlsearch = false

-- Make line numbers default
vim.opt.relativenumber = true
vim.opt.number = true

-- set indenting
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

-- Set the title of the shell
vim.opt.title = true
vim.opt.titlestring = 'nvim'

function UpdateTitleString()
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local filename = vim.fn.expand("%:t")
  vim.o.titlestring = cwd .. " - " .. filename
end

-- Füge Autocommands hinzu, die die UpdateTitleString-Funktion bei relevanten Ereignissen aufrufen
vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
  pattern = "*",
  callback = UpdateTitleString,
})

-- Enable mouse mode
vim.opt.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

vim.opt.autowriteall = true

-- Enable break indent
vim.opt.breakindent = true

-- searching
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Save undo history
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("XDG_CONFIG_HOME") .. "/nvim/.undodir"
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 50
vim.opt.timeoutlen = 200

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

vim.opt.scrolloff = 10

vim.opt.colorcolumn = "120"

-- keep selection on indentation
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })

-- highlight yanked text
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Enable `autoread` to trigger when files change on disk
vim.opt.autoread = true

-- Trigger `checktime` when focus is gained, or the buffer is entered or changed
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd("checktime")
    end
  end,
})

-- Show a notification after the file is changed on disk
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.api.nvim_echo({{"File changed on disk. Buffer reloaded.", "WarningMsg"}}, false, {})
  end,
})

vim.opt.spelllang = 'de_de,en_us'
vim.opt.spelloptions = camel
vim.opt.spell = true
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        vim.opt_local.spell = false
    end,
})

