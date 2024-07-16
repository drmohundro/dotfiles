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

local builtin = require('telescope.builtin')

wk.add({
  { '<leader>f',  '<cmd>Telescope live_grep_args<CR>',                desc = 'Live ripgrep search' },
  { '<leader>r',  builtin.oldfiles,                                   desc = 'Recent Files' },

  { '<leader>d',  '<cmd>Neotree reveal right toggle<CR>',             desc = 'Toggle directory tree' },

  -- Git
  { '<leader>g',  group = 'Git' },
  { '<leader>gl', "<cmd>lua require 'gitsigns'.blame_line()<CR>",     desc = 'Blame' },
  { '<leader>gd', '<cmd>Gitsigns diffthis HEAD<CR>',                  desc = 'Git Diff' },
  { '<leader>gt', '<cmd>lua lazygit_toggle()<CR>',                    desc = 'Toggle lazygit' },
  { '<leader>gf', builtin.git_files,                                  desc = 'Git Files' },
  { '<leader>go', builtin.git_status,                                 desc = 'Open changed file' },
  { '<leader>gb', builtin.git_branches,                               desc = 'Checkout branch' },
  { '<leader>gc', builtin.git_commits,                                desc = 'Checkout commit' },
  { '<leader>gC', builtin.git_bcommits,                               desc = 'Checkout commit(for current file)' },

  -- Key related
  { '<leader>k',  '<cmd>Legendary<CR>',                               desc = 'Show all commands' },

  -- LSP
  { '<leader>a',  desc = 'LSP' },
  { '<leader>aa', vim.lsp.buf.code_action,                            desc = 'Code Action' },
  { '<leader>af', vim.lsp.buf.format,                                 desc = 'Format' },
  { '<leader>ai', '<cmd>LspInfo<CR>',                                 desc = 'Info' },
  { '<leader>aI', '<cmd>Mason<CR>',                                   desc = 'Mason LSP Info' },
  { '<leader>aj', vim.diagnostic.goto_next,                           desc = 'Next Diagnostic' },
  { '<leader>ak', vim.diagnostic.goto_prev,                           desc = 'Prev Diagnostic' },
  { '<leader>al', vim.lsp.codelens.run,                               desc = 'CodeLens Action' },
  { '<leader>aq', vim.diagnostic.setloclist,                          desc = 'Quickfix' },
  { '<leader>ar', vim.lsp.buf.rename,                                 desc = 'Rename' },

  -- Telescope
  { '<leader>l',  desc = 'Telescope' },
  { '<leader>lr', builtin.oldfiles,                                   desc = 'Recent Files' },
  { '<leader>lb', builtin.buffers,                                    desc = 'Buffers' },
  { '<leader>lf', builtin.find_files,                                 desc = 'Find Files' },
  { '<leader>ld', '<cmd>Telescope diagnostics bufnr=0<CR>',           desc = 'Document Diagnostics' },
  { '<leader>ln', '<cmd>Telescope notify<CR>',                        desc = 'Notifications' },
  { '<leader>ls', builtin.lsp_document_symbols,                       desc = 'Document Symbols' },
  { '<leader>lS', builtin.lsp_dynamic_workspace_symbols,              desc = 'Workspace Symbols' },
  { '<leader>lw', builtin.diagnostics,                                desc = 'Workspace Diagnostics' },

  -- Trouble / Diagnostics
  { '<leader>t',  desc = 'Trouble (Diagnostics)' },
  { '<leader>tt', '<cmd>TroubleToggle<CR>',                           desc = 'Trouble Toggle' },
  { '<leader>tw', '<cmd>TroubleToggle lsp_workspace_diagnostics<CR>', desc = 'Workspace' },
  { '<leader>td', '<cmd>TroubleToggle lsp_document_diagnostics<CR>',  desc = 'Document' },
  { '<leader>tq', '<cmd>TroubleToggle quickfix<CR>',                  desc = 'QuickFix' },
  { '<leader>tl', '<cmd>TroubleToggle loclist<CR>',                   desc = 'LocList' },
  { '<leader>tr', '<cmd>TroubleToggle lsp_references<CR>',            desc = 'References' },

  -- Undotree
  { '<leader>u',  vim.cmd.UndotreeToggle,                             desc = 'Undotree' },
})
