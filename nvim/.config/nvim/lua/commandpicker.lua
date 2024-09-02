local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values

local M = {}

local function execute_command_in_terminal(command)
  -- Open a new terminal in float mode
  require('toggleterm').exec(command, 1, 12, "float")
end

function M.command_picker()
  pickers.new({}, {
    prompt_title = "Run Command",
    finder = finders.new_table {
      results = {
        { name = "Java: Build Maven Project", command = "mvn clean install" },
        { name = "Run Tests",                 command = "make test" },
        { name = "Deploy",                    command = "make deploy" }
      },
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        execute_command_in_terminal(selection.value.command)
      end)
      return true
    end
  }):find()
end

return M
