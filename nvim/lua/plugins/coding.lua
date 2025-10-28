return {
  {
    "nvim-mini/mini.comment",
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
    opts = {
      servers = {
        ["*"] = {
          keys = {
            -- { "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", has = "definition"},

            { "K", false },
            { "<C-h>", vim.lsp.buf.hover },
          },
        },
      },
    },
  },
}
