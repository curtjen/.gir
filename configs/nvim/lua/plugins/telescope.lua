return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local function _find_files_in_tab()
        require('telescope.builtin').find_files({
          attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd('tabe ' .. selection.path)
            end)
            map('n', '<CR>', function(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd('tabe ' .. selection.path)
            end)
            return true
          end
        })
      end

      local builtin = require("telescope.builtin")

      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      ---- KEYMAPS / SHORTCUTS ----
      -- Put keymaps and shortcuts here
      -- TODO: Fix this so it opens up new tab
      vim.keymap.set('n', '<C-p>', _find_files_in_tab, { noremap = true, silent = true, desc = "Find files in new tab" })
      -- TODO: Fix this so it opens up new tab
      vim.keymap.set('n', 'te', _find_files_in_tab, { noremap = true, silent = true, desc = "Find files in new tab" })
    end
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require('telescope').setup({
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {}
          }
        }
      })
      require('telescope').load_extension('ui-select')
    end
  },
}
