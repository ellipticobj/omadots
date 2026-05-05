-- HTML and CSS support
return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "html-lsp",
        "css-lsp",
        "emmet-ls",
        "prettierd",
        "rust-analyzer",
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
        "python",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "jsonc",
        "yaml",
        "toml",
        "rust",
        "go",
        "c",
        "cpp",
        "lua",
        "bash",
        "markdown",
        "vim",
        "regex",
      })
      opts.sync_install = false
      opts.incremental_sync = true
    end,
  },

  -- Rust LSP with inlay hints (Zed-style inline type checking)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              inlayHints = {
                enabled = true,
                parameterHints = { enabled = true },
                typeHints = { enabled = true, hideClosureInit = true },
                chainingHints = { enabled = true },
                closureReturnTypeHints = { enabled = "always" },
              },
            },
          },
        },
      },
      setup = {
        rust_analyzer = function(_, opts)
          local function on_attach(client, bufnr)
            vim.lsp.inlay_hint.enable(bufnr, true)
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(bufnr, true)
            end
          end
          opts.on_attach = vim.schedule_wrap(on_attach)
          require("lspconfig").rust_analyzer.setup(opts)
          return true
        end,
      },
    },
  },

  -- Auto-close HTML tags and brackets
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = {
          html = {
            tag = true, -- auto-close tags with treesitter
          },
        },
      })

      local ts_utils = require("nvim-treesitter.ts_utils")
      require("nvim-autopairs.ts_utils").on_attach_ts = function(char, event)
        if event.char == ">" then
          local node = ts_utils.get_node_at_cursor()
          if node and node:type() == "tag_name" then
            local parent = node:parent()
            if parent and parent:type() == "element" then
              local closing_tag = parent:child(parent:named_child_count() - 1)
              if closing_tag and closing_tag:type() == "end_tag" then
                return
              end
            end
            vim.schedule_wrap(function()
              require("nvim-autopairs")._on_keystroke({
                char = "<",
                key = "<",
                key_code = 60,
              })
            end)
          end
        end
      end
    end,
  },

  -- Snippet engine (VSCode-style)
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "honza/vim-snippets" },
    config = function()
      local ls = require("luasnip")
      ls.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })

      -- Load vim-snippets (VSCode-style snippets)
      require("luasnip.loaders.from_snipmate").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load()

      vim.keymap.set({ "i", "s" }, "<c-j>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { silent = true, desc = "Jump forward in snippet" })
      vim.keymap.set({ "i", "s" }, "<c-k>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true, desc = "Jump backward in snippet" })
      vim.keymap.set({ "i", "s" }, "<c-l>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = "Next snippet choice" })

      -- Tab to expand snippets (like VSCode)
      vim.keymap.set({ "i", "s" }, "<Tab>", function()
        if ls.expandable() then
          ls.expand()
        else
          return "<Tab>"
        end
      end, { expr = true, silent = true, desc = "Expand snippet or Tab" })
    end,
  },
}
