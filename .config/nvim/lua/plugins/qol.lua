return {
  -- File manager as a buffer — edit filesystem like text
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent dir (Oil)" },
    },
    opts = {
      default_file_explorer = false, -- keep neo-tree as default
    },
  },

  -- Symbol outline sidebar (functions, classes, methods)
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Aerial (symbols)" },
    },
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "{", "<cmd>AerialPrev<cr>", { buffer = bufnr, desc = "Aerial prev symbol" })
        vim.keymap.set("n", "}", "<cmd>AerialNext<cr>", { buffer = bufnr, desc = "Aerial next symbol" })
      end,
    },
  },

  -- Visual undo history tree
  {
    "mbbill/undotree",
    keys = {
      { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Undotree" },
    },
  },

  -- Quick file marks — jump between your 4 most-used files instantly
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require("harpoon")
      return {
        { "<leader>ha", function() harpoon:list():add() end,                        desc = "Harpoon add file" },
        { "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon menu" },
        { "<leader>h1", function() harpoon:list():select(1) end,                    desc = "Harpoon file 1" },
        { "<leader>h2", function() harpoon:list():select(2) end,                    desc = "Harpoon file 2" },
        { "<leader>h3", function() harpoon:list():select(3) end,                    desc = "Harpoon file 3" },
        { "<leader>h4", function() harpoon:list():select(4) end,                    desc = "Harpoon file 4" },
      }
    end,
    opts = {},
  },
}
