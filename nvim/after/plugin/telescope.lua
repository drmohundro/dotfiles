local actions = require('telescope.actions')

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        -- default key binding is <C-c> but I keep forgetting and I hit <esc> twice...
        ['<esc>'] = actions.close,
      },
    },
  },
  pickers = {
    oldfiles = {
      theme = 'ivy',
    },
    buffers = {
      sort_lastused = true,
      sort_mru = true,
      initial_mode = 'normal',
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
})

require('telescope').load_extension('fzf')
