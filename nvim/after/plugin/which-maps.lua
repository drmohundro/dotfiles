if vim.g.vscode then
  return
end

require('legendary').setup({ which_key = { auto_register = true } })

local wk = require('which-key')

wk.setup({
  plugins = {
    spelling = {
      enabled = true,
    },
  },
})

local builtin = require('telescope.builtin')

wk.register({
  f = { '<cmd>Telescope live_grep_args<CR>', 'Live ripgrep search' },
  r = { builtin.oldfiles, 'Recent Files' },

  d = { '<cmd>Neotree reveal right toggle<CR>', 'Toggle directory tree' },

  -- Git
  g = {
    name = 'Git',
    l = { "<cmd>lua require 'gitsigns'.blame_line()<CR>", 'Blame' },
    d = {
      '<cmd>Gitsigns diffthis HEAD<CR>',
      'Git Diff',
    },
    t = {
      '<cmd>lua lazygit_toggle()<CR>',
      'Toggle lazygit',
    },

    f = { builtin.git_files, 'Git Files' },
    o = { builtin.git_status, 'Open changed file' },
    b = { builtin.git_branches, 'Checkout branch' },
    c = { builtin.git_commits, 'Checkout commit' },
    C = {
      builtin.git_bcommits,
      'Checkout commit(for current file)',
    },
  },

  -- Key related
  k = { '<cmd>Legendary<CR>', 'Show all commands' },

  -- LSP
  a = {
    name = 'LSP',
    a = { vim.lsp.buf.code_action, 'Code Action' },
    f = { vim.lsp.buf.format, 'Format' },
    i = { '<cmd>LspInfo<CR>', 'Info' },
    I = { '<cmd>Mason<CR>', 'Mason LSP Info' },
    j = {
      vim.diagnostic.goto_next,
      'Next Diagnostic',
    },
    k = {
      vim.diagnostic.goto_prev,
      'Prev Diagnostic',
    },
    l = { vim.lsp.codelens.run, 'CodeLens Action' },
    q = { vim.diagnostic.setloclist, 'Quickfix' },
    r = { vim.lsp.buf.rename, 'Rename' },
  },

  -- Telescope
  l = {
    name = 'Telescope',
    r = { builtin.oldfiles, 'Recent Files' },
    b = { builtin.buffers, 'Buffers' },
    f = { builtin.find_files, 'Find Files' },
    d = {
      '<cmd>Telescope diagnostics bufnr=0<CR>',
      'Document Diagnostics',
    },
    n = { '<cmd>Telescope notify<CR>', 'Notifications' },
    s = { builtin.lsp_document_symbols, 'Document Symbols' },
    S = {
      builtin.lsp_dynamic_workspace_symbols,
      'Workspace Symbols',
    },
    w = {
      builtin.diagnostics,
      'Workspace Diagnostics',
    },
  },

  -- Trouble / Diagnostics
  t = {
    name = 'Trouble (Diagnostics)',
    t = { '<cmd>TroubleToggle<CR>', 'Trouble Toggle' },
    w = { '<cmd>TroubleToggle lsp_workspace_diagnostics<CR>', 'Workspace' },
    d = { '<cmd>TroubleToggle lsp_document_diagnostics<CR>', 'Document' },
    q = { '<cmd>TroubleToggle quickfix<CR>', 'QuickFix' },
    l = { '<cmd>TroubleToggle loclist<CR>', 'LocList' },
    r = { '<cmd>TroubleToggle lsp_references<CR>', 'References' },
  },

  -- Undotree
  u = { vim.cmd.UndotreeToggle, 'Undotree' },
}, {
  prefix = '<leader>',
})
