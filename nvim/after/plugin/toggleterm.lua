require('toggleterm').setup({
  -- size can be a number or function which is passed the current terminal
  size = 20,
  -- open_mapping = [[<c-\>]],
  open_mapping = [[<c-t>]],
  hide_numbers = true, -- hide the number column in toggleterm buffers
  start_in_insert = true,
  insert_mappings = true, -- whether or not the open mapping applies in insert mode
  persist_size = false,
  direction = 'horizontal',
  close_on_exit = true, -- close the terminal window when the process exits
  shell = 'fish', -- change the default shell
  -- This field is only relevant if direction is set to 'float'
  float_opts = {
    -- The border key is *almost* the same as 'nvim_open_win'
    -- see :h nvim_open_win for details on borders however
    -- the 'curved' border is a custom border type
    -- not natively supported but implemented in this plugin.
    border = 'curved',
    winblend = 3,
    highlights = {
      border = 'Normal',
      background = 'Normal',
    },
  },
})

function _G.set_terminal_keymaps()
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]])
  vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-W>h]])
  vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-W>j]])
  vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-W>k]])
  vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-W>l]])
end

if not vim.g.vscode then
  local Terminal = require('toggleterm.terminal').Terminal

  local lazygit = Terminal:new({
    cmd = 'lazygit',
    dir = 'git_dir',
    direction = 'float',
    float_opts = {
      border = 'double',
    },
    on_open = function(term)
      vim.cmd('startinsert!')
      vim.keymap.set('n', 'q', '<cmd>close<CR>', { noremap = true, silent = true, buffer = term.bufnr })
    end,
  })

  function _G.lazygit_toggle()
    lazygit:toggle()
  end
end
