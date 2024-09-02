return {
	"mfussenegger/nvim-jdtls",
	ft = "java",
	config = function()
		-- Load necessary dependencies
		local jdtls_ui = require("jdtls.ui")
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values

		-- Override the pick_many function with Telescope integration
		jdtls_ui.pick_many = function(items, prompt, label_f, opts)
			local co = coroutine.running()

			pickers
				.new(opts, {
					prompt_title = prompt,
					finder = finders.new_table({
						results = items,
						entry_maker = function(entry)
							return {
								value = entry,
								display = label_f(entry),
								ordinal = label_f(entry),
							}
						end,
					}),
					sorter = conf.generic_sorter(opts),
					attach_mappings = function(prompt_bufnr, map)
						actions.select_default:replace(function()
							local selections = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							coroutine.resume(co, { selections.value })
						end)
						map("i", "<CR>", actions.select_default)
						return true
					end,
				})
				:find()

			return coroutine.yield()
		end
	end,
}
