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
    '<esc><CMD>lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>',
    { silent = true }
  )

  vim.keymap.set('', '<c-l>', ':Telescope buffers<cr>')
  vim.keymap.set('', '<c-p>', ':Telescope find_files<cr>')

  vim.keymap.set('n', '<S-l>', ':BufferLineCycleNext<CR>')
  vim.keymap.set('n', '<S-h>', ':BufferLineCyclePrev<CR>')

  vim.keymap.set('', '<F4>', ':SymbolsOutline<CR>')

  vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

  local wk = require('which-key')

  wk.register({
    f = { '<cmd>Telescope live_grep_args<cr>', 'Live ripgrep search' },
    r = { '<cmd>Telescope oldfiles<cr>', 'Find recently opened files' },

    d = { '<cmd>Neotree reveal right toggle<cr>', 'Toggle directory tree' },

    -- Git
    g = {
      name = 'Git',
      l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", 'Blame' },
      o = { '<cmd>Telescope git_status<cr>', 'Open changed file' },
      b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
      c = { '<cmd>Telescope git_commits<cr>', 'Checkout commit' },
      C = {
        '<cmd>Telescope git_bcommits<cr>',
        'Checkout commit(for current file)',
      },
      d = {
        '<cmd>Gitsigns diffthis HEAD<cr>',
        'Git Diff',
      },
      t = {
        '<cmd>lua lazygit_toggle()<cr>',
        'Toggle lazygit',
      },
    },

    -- LSP
    l = {
      name = 'LSP',
      a = { '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Code Action' },
      d = {
        '<cmd>Telescope diagnostics bufnr=0<cr>',
        'Document Diagnostics',
      },
      w = {
        '<cmd>Telescope diagnostics<cr>',
        'Workspace Diagnostics',
      },
      f = { '<cmd>lua vim.lsp.buf.format()<cr>', 'Format' },
      i = { '<cmd>LspInfo<cr>', 'Info' },
      I = { '<cmd>Mason<cr>', 'Mason LSP Info' },
      j = {
        '<cmd>lua vim.diagnostic.goto_next()<cr>',
        'Next Diagnostic',
      },
      k = {
        '<cmd>lua vim.diagnostic.goto_prev()<cr>',
        'Prev Diagnostic',
      },
      l = { '<cmd>lua vim.lsp.codelens.run()<cr>', 'CodeLens Action' },
      q = { '<cmd>lua vim.diagnostic.setloclist()<cr>', 'Quickfix' },
      r = { '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename' },
      s = { '<cmd>Telescope lsp_document_symbols<cr>', 'Document Symbols' },
      S = {
        '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>',
        'Workspace Symbols',
      },
    },

    -- Trouble toggling
    t = {
      name = 'Diagnostics',
      t = { '<cmd>TroubleToggle<cr>', 'trouble' },
      w = { '<cmd>TroubleToggle lsp_workspace_diagnostics<cr>', 'workspace' },
      d = { '<cmd>TroubleToggle lsp_document_diagnostics<cr>', 'document' },
      q = { '<cmd>TroubleToggle quickfix<cr>', 'quickfix' },
      l = { '<cmd>TroubleToggle loclist<cr>', 'loclist' },
      r = { '<cmd>TroubleToggle lsp_references<cr>', 'references' },
    },
  }, {
    prefix = '<leader>',
  })
end
