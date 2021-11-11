local g = vim.g -- a table to access global variables

-- see https://github.com/numToStr/Comment.nvim/issues/14#issuecomment-939230851
local Ut = require('Comment.utils')
local Op = require('Comment.opfunc')

function _G.__toggle_visual(vmode)
  local lcs, rcs = Ut.unwrap_cstr(vim.bo.commentstring)
  local srow, erow, lines = Ut.get_lines(vmode, Ut.ctype.line)

  Op.linewise({
    cfg = { padding = true, ignore = nil },
    cmode = Ut.cmode.toggle,
    lines = lines,
    lcs = lcs,
    rcs = rcs,
    srow = srow,
    erow = erow,
  })
end

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
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

if not g.vscode then
  local wk = require('which-key')

  wk.register({
    f = { '<cmd>Telescope live_grep<cr>', 'Live ripgrep search' },
    r = { '<cmd>Telescope oldfiles<cr>', 'Find recently opened files' },

    d = { '<cmd>NvimTreeToggle<cr>', 'Toggle directory tree' },

    p = {
      name = 'Packer',
      c = { '<cmd>PackerCompile<cr>', 'Compile' },
      i = { '<cmd>PackerInstall<cr>', 'Install' },
      r = { "<cmd>lua require('lvim.plugin-loader').recompile()<cr>", 'Re-compile' },
      s = { '<cmd>PackerSync<cr>', 'Sync' },
      S = { '<cmd>PackerStatus<cr>', 'Status' },
      u = { '<cmd>PackerUpdate<cr>', 'Update' },
    },

    g = {
      name = 'Git',
      j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", 'Next Hunk' },
      k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", 'Prev Hunk' },
      l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", 'Blame' },
      p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", 'Preview Hunk' },
      r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", 'Reset Hunk' },
      R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", 'Reset Buffer' },
      s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", 'Stage Hunk' },
      u = {
        "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
        'Undo Stage Hunk',
      },
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
    },
  }, {
    prefix = '<leader>',
  })

  map('', '\\\\', '<esc><cmd>lua __toggle_visual(vim.fn.visualmode())<cr>', { silent = true })

  map('', '<c-l>', ':Telescope buffers<cr>')
  map('', '<c-p>', ':Telescope find_files<cr>')

  map('n', '<S-l>', ':BufferLineCycleNext<CR>')
  map('n', '<S-h>', ':BufferLineCyclePrev<CR>')
end
