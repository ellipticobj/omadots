-- HTML and CSS support (no dedicated LazyVim extra exists for these)
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "html-lsp",
        "css-lsp",
        "emmet-ls",
        "prettierd",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
        emmet_ls = {
          filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact" },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "html",
        "css",
      })
    end,
  },
}
