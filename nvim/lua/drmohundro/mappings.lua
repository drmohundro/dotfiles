-- toggle showing whitespace
vim.keymap.set('n', '<leader>s', ':set nolist!<cr>', { silent = true })

-- use J/K to go half page up/down
vim.keymap.set('n', 'J', '<C-d>zz')
vim.keymap.set('x', 'J', '<C-d>zz')
vim.keymap.set('n', 'K', '<C-u>zz')
vim.keymap.set('x', 'K', '<C-u>zz')

-- the `zz` is to center results
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- keep search results centered
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- up/down work as expected with word wrapping on
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', 'gj', 'j')
vim.keymap.set('n', 'gj', 'j')

-- clear search highlighting
vim.keymap.set('n', '<esc>', ':nohlsearch<cr><esc>', { silent = true })

-- move selection up or down in visual mode
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv")

-- quickfix and location list navigation
vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

if vim.g.vscode then
  -- HACK: get around weird issues with o|O keys in VSCode Neovim... see https://github.com/asvetliakov/vscode-neovim/issues/485#issuecomment-792292205
  vim.keymap.set('n', 'o', "<cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>i", { silent = true })
  vim.keymap.set('n', 'O', "<cmd>call VSCodeNotify('editor.action.insertLineBefore')<cr>i", { silent = true })
else
  vim.keymap.set(
    '',
    '\\\\',
    '<esc><CMD>lua require("Comment.api").locked("comment.linewise")(vim.fn.visualmode())<CR>',
    { silent = true }
  )

  local builtin = require('telescope.builtin')

  vim.keymap.set('', '<c-l>', builtin.buffers, {})
  vim.keymap.set('', '<c-p>', builtin.find_files, {})

  vim.keymap.set('n', '<S-l>', ':BufferLineCycleNext<CR>')
  vim.keymap.set('n', '<S-h>', ':BufferLineCyclePrev<CR>')

  vim.keymap.set('', '<F4>', ':SymbolsOutline<CR>')

  vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

  -- NOTE: see also which-maps.lua
end
