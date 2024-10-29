return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-smart-history.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "kkharji/sqlite.lua",
    },
    keys = {
      -- browse plugin files
      {
        "<leader>fp",
        function()
          require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
      -- I don't see much utility in pickers going into normal mode when we
      -- press esc, so instead just exit the picker entirely
      {
        mode = "i",
        "<esc>",
        function()
          require("telescope.actions").close(vim.fn["bufnr"]("%"))
        end,
      },
      -- Also map jk to exit
      {
        mode = "i",
        "jk",
        function()
          require("telescope.actions").close(vim.fn["bufnr"]("%"))
        end,
      },
      -- faster and more familiar file/buffer switching
      { mode = "n", ";", "<leader>,", desc = "Switch buffers", remap = true },
      { mode = "n", "<C-p>", "<leader>ff", desc = "Find files (Root Dir),", remap = true },
      {
        mode = "i",
        "<c-down>",
        function()
          require("telescope.actions").cycle_history_next(vim.fn["bufnr"]("%"))
        end,
      },
      {
        mode = "i",
        "<c-up>",
        function()
          require("telescope.actions").cycle_history_prev(vim.fn["bufnr"]("%"))
        end,
      },
    },
    opts = {
      defaults = {
        layout_strategy = "vertical",
      },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "vertical",
          history = {
            path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
            limit = 200,
          },
        },
      })
      os.execute("mkdir -p ~/.local/share/nvim/databases/")
      require("telescope").load_extension("smart_history")
      require("telescope").load_extension("frecency")
    end,
  },
}
