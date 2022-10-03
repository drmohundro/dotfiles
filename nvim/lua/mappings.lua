local g = vim.g -- a table to access global variables
local Terminal = require('toggleterm.terminal').Terminal

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

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

-- toggle showing whitespace
map('n', '<leader>s', ':set nolist!<cr>', { silent = true })

map('n', 'J', '<c-d>')
map('x', 'J', '<c-d>')
map('n', 'K', '<c-u>')
map('x', 'K', '<c-u>')

-- up/down work as expected with word wrapping on
map('n', 'j', 'gj')
map('n', 'k', 'gk')
map('n', 'gj', 'j')
map('n', 'gj', 'j')

map('', 'H', '^')
map('', 'L', '$')

-- clear search highlighting
map('n', '<esc>', ':nohlsearch<cr><esc>', { silent = true })

if g.vscode then
  -- HACK: get around weird issues with o|O keys in VSCode Neovim... see https://github.com/asvetliakov/vscode-neovim/issues/485#issuecomment-792292205
  map('n', 'o', "<cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>i", { silent = true })
  map('n', 'O', "<cmd>call VSCodeNotify('editor.action.insertLineBefore')<cr>i", { silent = true })
else
  map('', '\\\\', '<esc><CMD>lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>', { silent = true })

  map('', '<c-l>', ':Telescope buffers<cr>')
  map('', '<c-p>', ':Telescope find_files<cr>')

  map('n', '<S-l>', ':BufferLineCycleNext<CR>')
  map('n', '<S-h>', ':BufferLineCyclePrev<CR>')

  map('', '<F4>', ':SymbolsOutline<CR>')

  vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

  local wk = require('which-key')

  wk.register({
    f = { '<cmd>Telescope live_grep_args<cr>', 'Live ripgrep search' },
    r = { '<cmd>Telescope oldfiles<cr>', 'Find recently opened files' },

    d = { '<cmd>Neotree reveal right toggle<cr>', 'Toggle directory tree' },

    -- Packer
    p = {
      name = 'Packer',
      c = { '<cmd>PackerCompile<cr>', 'Compile' },
      i = { '<cmd>PackerInstall<cr>', 'Install' },
      r = { "<cmd>lua require('lvim.plugin-loader').recompile()<cr>", 'Re-compile' },
      s = { '<cmd>PackerSync<cr>', 'Sync' },
      S = { '<cmd>PackerStatus<cr>', 'Status' },
      u = { '<cmd>PackerUpdate<cr>', 'Update' },
    },

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
      a = { "<cmd>lua require('lvim.core.telescope').code_actions()<cr>", 'Code Action' },
      d = {
        '<cmd>Telescope lsp_document_diagnostics<cr>',
        'Document Diagnostics',
      },
      w = {
        '<cmd>Telescope lsp_workspace_diagnostics<cr>',
        'Workspace Diagnostics',
      },
      f = { '<cmd>lua vim.lsp.buf.format()<cr>', 'Format' },
      i = { '<cmd>LspInfo<cr>', 'Info' },
      I = { '<cmd>Mason<cr>', 'Mason LSP Info' },
      j = {
        '<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {border = lvim.lsp.popup_border}})<cr>',
        'Next Diagnostic',
      },
      k = {
        '<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = lvim.lsp.popup_border}})<cr>',
        'Prev Diagnostic',
      },
      l = { '<cmd>lua vim.lsp.codelens.run()<cr>', 'CodeLens Action' },
      p = {
        name = 'Peek',
        d = { "<cmd>lua require('lvim.lsp.peek').Peek('definition')<cr>", 'Definition' },
        t = { "<cmd>lua require('lvim.lsp.peek').Peek('typeDefinition')<cr>", 'Type Definition' },
        i = { "<cmd>lua require('lvim.lsp.peek').Peek('implementation')<cr>", 'Implementation' },
      },
      q = { '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', 'Quickfix' },
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
