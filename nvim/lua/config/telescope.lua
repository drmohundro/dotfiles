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
})
