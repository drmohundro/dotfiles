if vim.g.vscode then
  return
end

require('legendary').setup({
  extensions = {
    which_key = { auto_register = true },
  },
})

local wk = require('which-key')

wk.setup({
  plugins = {
    spelling = {
      enabled = true,
    },
  },
})

wk.add({
  { '<leader>f', [[<cmd>FzfLua live_grep_native<CR>]], desc = 'Live ripgrep search' },
  { '<leader>r', [[<cmd>FzfLua oldfiles<CR>]], desc = 'Recent Files' },

  { '<leader>d', '<cmd>Neotree reveal right toggle<CR>', desc = 'Toggle directory tree' },

  -- Git
  { '<leader>g', group = 'Git' },
  { '<leader>gl', "<cmd>lua require 'gitsigns'.blame_line()<CR>", desc = 'Blame' },
  { '<leader>gd', '<cmd>Gitsigns diffthis HEAD<CR>', desc = 'Git Diff' },
  { '<leader>gt', '<cmd>lua lazygit_toggle()<CR>', desc = 'Toggle lazygit' },
  { '<leader>gf', [[<cmd>FzfLua git_files<CR>]], desc = 'Git Files' },
  { '<leader>go', [[<cmd>FzfLua git_status<CR>]], desc = 'Open changed file' },
  { '<leader>gb', [[<cmd>FzfLua git_branches<CR>]], desc = 'Checkout branch' },
  { '<leader>gc', [[<cmd>FzfLua git_commits<CR>]], desc = 'Checkout commit' },
  { '<leader>gC', [[<cmd>FzfLua git_bcommits<CR>]], desc = 'Checkout commit(for current file)' },

  -- Key related
  { '<leader>k', '<cmd>Legendary<CR>', desc = 'Show all commands' },

  -- LSP
  { '<leader>a', desc = 'LSP' },
  { '<leader>aa', vim.lsp.buf.code_action, desc = 'Code Action' },
  { '<leader>af', vim.lsp.buf.format, desc = 'Format' },
  { '<leader>ai', '<cmd>LspInfo<CR>', desc = 'Info' },
  { '<leader>aI', '<cmd>Mason<CR>', desc = 'Mason LSP Info' },
  { '<leader>aj', vim.diagnostic.goto_next, desc = 'Next Diagnostic' },
  { '<leader>ak', vim.diagnostic.goto_prev, desc = 'Prev Diagnostic' },
  { '<leader>al', vim.lsp.codelens.run, desc = 'CodeLens Action' },
  { '<leader>aq', vim.diagnostic.setloclist, desc = 'Quickfix' },
  { '<leader>ar', vim.lsp.buf.rename, desc = 'Rename' },

  -- fzf-lua
  { '<leader>l', desc = 'FzfLua' },
  { '<leader>lr', [[<cmd>FzfLua oldfiles<CR>]], desc = 'Recent Files' },
  { '<leader>lb', [[<cmd>FzfLua buffers<CR>]], desc = 'Buffers' },
  { '<leader>lf', [[<cmd>FzfLua files<CR>]], desc = 'Find Files' },
  { '<leader>ld', [[<cmd>FzfLua diagnostics_document bufnr=0<CR>]], desc = 'Document Diagnostics' },
  { '<leader>ln', [[<cmd>FzfLua notify<CR>]], desc = 'Notifications' },
  { '<leader>ls', [[<cmd>FzfLua lsp_document_symbols<CR>]], desc = 'Document Symbols' },
  { '<leader>lS', [[<cmd>FzfLua lsp_workspace_symbols<CR>]], desc = 'Workspace Symbols' },
  { '<leader>lw', [[<cmd>FzfLua diagnostics_workspace<CR>]], desc = 'Workspace Diagnostics' },

  -- Trouble / Diagnostics
  { '<leader>t', desc = 'Trouble (Diagnostics)' },
  { '<leader>tt', [[<cmd>Trouble<CR>]], desc = 'Trouble Toggle' },
  { '<leader>tw', [[<cmd>Trouble lsp_workspace_diagnostics<CR>]], desc = 'Workspace' },
  { '<leader>td', [[<cmd>Trouble lsp_document_diagnostics<CR>]], desc = 'Document' },
  { '<leader>tq', [[<cmd>Trouble quickfix<CR>]], desc = 'QuickFix' },
  { '<leader>tl', [[<cmd>Trouble loclist<CR>]], desc = 'LocList' },
  { '<leader>tr', [[<cmd>Trouble lsp_references<CR>]], desc = 'References' },

  -- Undotree
  { '<leader>u', vim.cmd.UndotreeToggle, desc = 'Undotree' },
})
