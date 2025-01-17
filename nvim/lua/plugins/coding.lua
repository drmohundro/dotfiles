return {
  {
    "echasnovski/mini.comment",
    opts = {
      mappings = {
        comment = "\\\\",
        comment_line = "\\\\",
        comment_visual = "\\\\",
      },
    },
  },

  {
    "NeogitOrg/neogit",
    event = "VeryLazy",
  },

  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- disable K for hover
      keys[#keys + 1] = { "K", false }
      -- use C-h instead
      keys[#keys + 1] = { "<C-h>", vim.lsp.buf.hover }
    end,
  },
}
