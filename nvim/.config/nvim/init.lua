-- This has to be commented out when downloading spell files, as they use netrw somehow
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("remaps")
require("comparewithclipboard")

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	callback = function()
		require("options")

		vim.api.nvim_create_user_command("CopyFilePath", function()
			vim.fn.setreg("+", vim.fn.expand("%:p"))
		end, { desc = "Copy file path to clipboard" })
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require("lazy").setup({
	-- NOTE: First, some plugins that don't require any configuration

	-- Git related plugins
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",

	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	-- NOTE: This is where your plugins related to LSP can be installed.
	--  The configuration is done below. Search for lspconfig to find it below.
	{
		-- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			"folke/neodev.nvim",
		},
	},

	{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
	{
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets
					-- This step is not supported in many windows environments
					-- Remove the below condition to re-enable on windows
					if vim.fn.has("win32") == 1 then
						return
					end
					return "make install_jsregexp"
				end)(),
				"L3MON4D3/LuaSnip",
			},

			-- Adds LSP completion capabilities
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",

			-- Adds a number of user-friendly snippets
			"rafamadriz/friendly-snippets",
		},
	},

	-- Useful plugin to show you pending keybinds.
	{ "akinsho/toggleterm.nvim", opts = {} },
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		config = function()
			require("which-key").setup()
			require("which-key").add({
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			})
		end,
	},
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Jump to next hunk" })

				map({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Jump to previous hunk" })

				-- Actions
				-- visual mode
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "stage git hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "reset git hunk" })
				-- normal mode
				map("n", "<leader>hs", gs.stage_hunk, { desc = "git stage hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { desc = "git reset hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "git Stage buffer" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "git Reset buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "preview git hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = false })
				end, { desc = "git blame line" })
				map("n", "<leader>hd", gs.diffthis, { desc = "git diff against index" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "git diff against last commit" })

				-- Toggles
				map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
				map("n", "<leader>td", gs.toggle_deleted, { desc = "toggle git show deleted" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
			end,
		},
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function(_, _)
			require("tokyonight").setup({
				style = "moon",
				dark_float = false,

				-- transparent = true,
				terminal_colors = true,
				on_highlights = function(highlights, colors)
					highlights.TabLineSel = {
						bg = colors.bg_highlight,
					}
					highlights.SpellBad = {
						sp = colors.warning,
						undercurl = true,
					}
				end,
				on_colors = function(colors)
					colors.bg_float = "none"
				end,
				styles = {
					floats = "transparent",
				},
			})
			-- vim.g.tokyonight_transparent = true
			-- vim.g.tokyonight_dark_float = false
			-- vim.g.tokyonight_dark_sidebar = false
			-- vim.g.tokyonight_transparent_sidebar = true
			-- vim.g.tokyonight_colors = { bg_float = "none" }

			vim.cmd.colorscheme("tokyonight")
		end,
	},
	-- {
	--   -- Theme inspired by Atom
	--   'navarasu/onedark.nvim',
	--   priority = 1000,
	--   config = function()
	--     vim.cmd.colorscheme 'onedark'
	--   end,
	-- },

	{
		-- Set lualine as statusline
		"nvim-lualine/lualine.nvim",
		-- See `:help lualine.txt`
		opts = {
			options = {
				section_separators = "",
				component_separators = "|",
				theme = "auto",
				icons_enabled = true,
			},
			sections = {
				-- left
				lualine_a = {
					{
						function()
							return " " .. require("lualine.components.mode")()
						end,
					},
				},
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "filename", path = 1 } },

				-- right
				lualine_x = { "g:zoom#statustext", "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			extensions = { "quickfix", "fugitive", "fzf" },
		},
	},
	{
		-- Add indentation guides even on blank lines
		"lukas-reineke/indent-blankline.nvim",
		-- Enable `lukas-reineke/indent-blankline.nvim`
		-- See `:help ibl`
		main = "ibl",
		opts = {},
	},

	-- "gc" to comment visual regions/lines
	{ "numToStr/Comment.nvim", opts = {} },
	-- use this for faster file finding
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- calling `setup` is optional for customization
			require("fzf-lua").setup({})
		end,
	},
	-- Fuzzy Finder (files, lsp, etc)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			{
				"nvim-telescope/telescope-live-grep-args.nvim",
				-- This will not install any breaking changes.
				-- For major updates, this must be adjusted manually.
				version = "^1.0.0",
			},
			{ "nvim-lua/plenary.nvim" },
			-- Fuzzy Finder Algorithm which heavily favors matches on filenames instead of pathnames
			{ "natecraddock/telescope-zf-native.nvim" },
			-- Fuzzy Finder Algorithm which requires local dependencies to be built.
			-- Only load if `make` is available. Make sure you have the system
			-- requirements installed.
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				-- NOTE: If you are having trouble with this installation,
				--       refer to the README for telescope-fzf-native for more instructions.
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
	},

	{
		-- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
	},
	{
		-- Highlight, edit, and navigate code
		"nvim-treesitter/playground",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	require("kickstart.plugins.autoformat"),
	require("kickstart.plugins.debug"),
	{ import = "custom.plugins" },
	--
})

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
function ToggleVirtualText()
	local current_state = vim.diagnostic.config()["virtual_text"]
	vim.diagnostic.config({ virtual_text = not current_state })
end

vim.api.nvim_set_keymap("n", "<leader>dt", ":lua ToggleVirtualText()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- For telescope always show the filename first
local function filename_first(_, path)
	local tail = vim.fs.basename(path)
	local parent = vim.fs.dirname(path)
	if parent == "." then
		return tail
	end
	return string.format("%s\t\t%s", tail, parent)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopeResults",
	callback = function(ctx)
		vim.api.nvim_buf_call(ctx.buf, function()
			vim.fn.matchadd("TelescopeParent", "\t\t.*$")
			vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
		end)
	end,
})

local resized_group = vim.api.nvim_create_augroup("VimResizedGroup", { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		local new_scroll = math.floor(vim.o.lines / 4)
		vim.o.scroll = new_scroll
	end,
	group = resized_group,
	pattern = "*",
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		path_display = filename_first,
		mappings = {
			i = {
				["<C-u>"] = false,
				["<C-d>"] = false,
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
			},
		},
	},
	pickers = {
		buffers = {
			mappings = {
				i = {
					["<C-d>"] = "delete_buffer",
				},
			},
		},
	},
	extensions = {
		["zf-native"] = {
			-- options for sorting file-like items
			file = {
				-- override default telescope file sorter
				enable = true,
				-- highlight matching text in results
				highlight_results = true,
				-- enable zf filename match priority
				match_filename = true,
				-- optional function to define a sort order when the query is empty
				initial_sort = nil,
				-- set to false to enable case sensitive matching
				smart_case = true,
			},

			-- options for sorting all other items
			generic = {
				-- override default telescope generic item sorter
				enable = true,
				-- highlight matching text in results
				highlight_results = true,
				-- disable zf filename match priority
				match_filename = false,
				-- optional function to define a sort order when the query is empty
				initial_sort = nil,
				-- set to false to enable case sensitive matching
				smart_case = true,
			},
		},
	},
	-- extensions = {
	--   fzf = {
	--     fuzzy = true,
	--     override_generic_sorter = false,
	--     override_file_sorter = true,
	--     sorter = require('telescope.sorters').get_fzy_sorter,
	--     case_mode = "smart_case",
	--   },
	-- },
})

-- Enable telescope fzf native, if installed
-- pcall(require('telescope').load_extension, 'fzf')
  require("telescope").load_extension("zf-native")
  require("telescope").load_extension("live_grep_args")
  require("telescope").load_extension("ui-select")

  -- Telescope live_grep in git root
  -- Function to find the git root directory based on the current buffer's path
  local function find_git_root()
    -- Use the current buffer's path as the starting point for the git search
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir
    local cwd = vim.fn.getcwd()
    -- If the buffer is not associated with a file, return nil
    if current_file == "" then
      current_dir = cwd
    else
      -- Extract the directory from the current file's path
      current_dir = vim.fn.fnamemodify(current_file, ":h")
    end

    -- Find the Git root directory from the current file's path
    local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
    if vim.v.shell_error ~= 0 then
      print("Not a git repository. Searching on current working directory")
      return cwd
    end
    return git_root
  end

  -- Custom live_grep function to search in git root
  local function live_grep_git_root()
    local git_root = find_git_root()
    if git_root then
      require("telescope.builtin").live_grep({
        search_dirs = { git_root },
      })
    end
  end

  vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

  local common_settings = {
    previewer = true,
    winblend = 8,
    layout_strategy = "horizontal",
    layout_config = { prompt_position = "bottom", height = 0.8, width = 0.8 },
    borderchars = {
      prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      results = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
  }

  local function with_common_settings(fn, custom_settings)
    return function()
      local settings = vim.tbl_deep_extend("force", common_settings, custom_settings or {})
      require("telescope.builtin")[fn](require("telescope.themes").get_dropdown(settings))
    end
  end

  vim.keymap.set("n", "<leader>?", with_common_settings("oldfiles"), { desc = "[?] Find recently opened files" })
  vim.keymap.set("n", "<leader><space>", with_common_settings("buffers"), { desc = "[ ] Find existing buffers" })
  vim.keymap.set(
    "n",
    "<leader>/",
    with_common_settings("current_buffer_fuzzy_find"),
    { desc = "[/] Fuzzily search in current buffer" }
  )
  vim.keymap.set("n", "<leader>gs", with_common_settings("git_stash"), { desc = "[G]it [S]tash" })
  vim.keymap.set("n", "<leader>ga", with_common_settings("git_status"), { desc = "[G]it St[a]tus" })
  vim.keymap.set("n", "<leader>tb", with_common_settings("builtin"), { desc = "[T]elescope [B]uiltin" })
  local function telescope_live_grep_open_files()
    local settings = vim.tbl_deep_extend("force", common_settings, {
      grep_open_files = true,
      prompt_title = "Live Grep in Open Files",
    })
    require("telescope.builtin").live_grep(require("telescope.themes").get_dropdown(settings))
  end

  local function telescope_live_grep_args()
    local settings = vim.tbl_deep_extend("force", common_settings, {
      prompt_title = "Live Grep with args",
    })

    require("telescope").extensions.live_grep_args.live_grep_args(require("telescope.themes").get_dropdown(settings))
  end

  vim.keymap.set("n", "<leader>cp", ':lua require("commandpicker").command_picker()<CR>', { desc = "[C]ommand [P]icker" })
  vim.keymap.set("n", "<leader>s/", telescope_live_grep_open_files, { desc = "[S]earch [/] in Open Files" })
  vim.keymap.set("n", "<leader>ss", with_common_settings("builtin"), { desc = "[S]earch [S]elect Telescope" })
  vim.keymap.set("n", "<leader>gf", with_common_settings("git_files"), { desc = "Search [G]it [F]iles" })
  vim.keymap.set("n", "<leader>gb", with_common_settings("git_branches"), { desc = "Search [G]it [B]ranches" })
  vim.keymap.set("n", "<leader>sf", with_common_settings("find_files"), { desc = "[S]earch [F]iles" })
  vim.keymap.set(
    "n",
    "<leader>fsf",
    "<cmd>lua require('fzf-lua').files()<CR>",
    { desc = "[F]ast [S]earch [F]ile", silent = true }
  )
  vim.keymap.set("n", "<leader>sh", with_common_settings("help_tags"), { desc = "[S]earch [H]elp" })
  vim.keymap.set("n", "<leader>sw", with_common_settings("grep_string"), { desc = "[S]earch current [W]ord" })
  -- vim.keymap.set('n', '<leader>sg', with_common_settings('live_grep'), { desc = '[S]earch by [G]rep' })
  vim.keymap.set("n", "<leader>sg", telescope_live_grep_args, { desc = "[S]earch by [G]rep" })
  vim.keymap.set("n", "<leader>sG", ":LiveGrepGitRoot<cr>", { desc = "[S]earch by [G]rep on Git Root" })
  vim.keymap.set("n", "<leader>sd", with_common_settings("diagnostics"), { desc = "[S]earch [D]iagnostics" })
  vim.keymap.set("n", "<leader>sr", with_common_settings("resume"), { desc = "[S]earch [R]esume" })

  -- [[ Configure Treesitter ]]
  -- See `:help nvim-treesitter`
  -- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
  vim.defer_fn(function()
    require("nvim-treesitter.configs").setup({
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        "c",
        "cpp",
        "go",
        "lua",
        "python",
        "rust",
        "tsx",
        "java",
        "javascript",
        "typescript",
        "vimdoc",
        "vim",
        "bash",
        "yaml",
        "kotlin",
      },

      -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
      auto_install = true,
      -- Install languages synchronously (only applied to `ensure_installed`)
      sync_install = false,
      -- List of parsers to ignore installing
      ignore_install = {},
      -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
      modules = {},
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = "<cs-space>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]fs"] = "@function.outer",
            ["]cs"] = "@class.outer",
          },
          goto_next_end = {
            ["]fe"] = "@function.outer",
            ["]ce"] = "@class.outer",
          },
          goto_previous_start = {
            ["[fs"] = "@function.outer",
            ["[cs"] = "@class.outer",
          },
          goto_previous_end = {
            ["[fe"] = "@function.outer",
            ["[ce"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
      },
    })
  end, 0)

  -- local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
  --
  -- -- Repeat movement with ; and ,
  -- -- ensure ; goes forward and , goes backward regardless of the last direction
  -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
  -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

  -- [[ Configure LSP ]]
  --  This function gets run when an LSP connects to a particular buffer.
  local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
      if desc then
        desc = "LSP: " .. desc
      end

      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>ca", function()
      vim.lsp.buf.code_action({ context = { only = { "quickfix", "refactor", "source" } } })
    end, "[C]ode [A]ction")

    nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
    nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
    nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
    nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    nmap("<C-s>", vim.lsp.buf.signature_help, "Signature Documentation")

    -- Lesser used LSP functionality
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    -- nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    -- nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    -- nmap('<leader>f', vim.lsp.buf.format, '[F]ormat')
    nmap("<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
      vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })
  end

  require("mason-tool-installer").setup({
    ensure_installed = {
      "java-debug-adapter",
      "java-test",
    },
  })

  -- mason-lspconfig requires that these setup functions are called in this order
  -- before setting up the servers.
  require("mason").setup()
  require("mason-lspconfig").setup()

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --
  --  Add any additional override configuration in the following tables. They will be passed to
  --  the `settings` field of the server config. You must look up that documentation yourself.
  --
  --  If you want to override the default filetypes that your language server will attach to you can
  --  define the property 'filetypes' to the map in question.
  local servers = {
    clangd = {},
    gopls = {},
    pyright = {},
    rust_analyzer = {},
    tsserver = {},
    -- vale = {},
    groovyls = {},
    html = { filetypes = { "html", "twig", "hbs" } },
    jdtls = {},
    lua_ls = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  }

  -- Setup neovim lua configuration
  require("neodev").setup()

  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

  -- Ensure the servers above are installed
  local mason_lspconfig = require("mason-lspconfig")

  mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
  })

  mason_lspconfig.setup_handlers({
    function(server_name)
      if server_name ~= "jdtls" then
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = servers[server_name],
          filetypes = (servers[server_name] or {}).filetypes,
        })
      end
    end,
  })

  -- [[ Configure nvim-cmp ]]
  -- See `:help cmp`
  local cmp = require("cmp")
  local luasnip = require("luasnip")
  require("luasnip.loaders.from_vscode").lazy_load()
  luasnip.config.setup({})

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    completion = {
      completeopt = "menu,menuone,noinsert",
    },
    sorting = {
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete({}),
      ["<C-y>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = {
      -- { name = 'copilot' },
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "rg", keyword_length = 3 },
      { name = "obsidian" },
      { name = "obsidian_new" },
      { name = "obsidian_tags" },
    },
  })

  require("filetypedetection")
  -- The line beneath this is called `modeline`. See `:help modeline`
  -- vim: ts=2 sts=2 sw=2 et
