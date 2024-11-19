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
      { mode = "n", ";", "<leader>,", desc = "Switch buffers", remap = true },
      { mode = "n", "<C-p>", "<leader>ff", desc = "Find files (Root Dir),", remap = true },
      -- browse yank history
      {
        "<leader>sy",
        require("telescope").extensions.yank_history.yank_history,
        desc = "Yank History",
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
          mappings = {
            i = {
              ["<C-Down>"] = require("telescope.actions").cycle_history_next,
              ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
              -- I don't see much utility in pickers going into normal mode
              -- when we press esc, so instead just exit the picker entirely
              ["jk"] = require("telescope.actions").close,
              ["<esc>"] = require("telescope.actions").close,
            },
          },
        },
      })
      os.execute("mkdir -p ~/.local/share/nvim/databases/")
      require("telescope").load_extension("smart_history")
      require("telescope").load_extension("frecency")
      require("telescope").load_extension("yank_history")
    end,
  },
}
