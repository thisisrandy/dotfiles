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
      {
        -- Also bound by default to <leader>p (for paste)
        "<leader>sp",
        require("telescope").extensions.yank_history.yank_history,
        desc = "Open Yank History",
      },
      {
        "<leader>gr",
        require("telescope.builtin").git_branches,
        desc = "B[r]anches",
      },
      {
        "<leader>gt",
        require("telescope.builtin").git_stash,
        desc = "S[t]ashes",
      },
      {
        "<leader>gu",
        require("telescope.builtin").git_bcommits,
        desc = "B[u]ffer Commits",
      },
    },
    config = function(_, opts)
      require("telescope").setup(vim.tbl_deep_extend("force", opts, {
        defaults = {
          layout_strategy = "vertical",
          history = {
            path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
            limit = 200,
          },
          mappings = {
            i = {
              -- Exit the picker immediately on jk, but still allow entering
              -- normal mode w/esc. This is especially useful e.g. for
              -- yank_history
              ["jk"] = require("telescope.actions").close,
            },
          },
          dynamic_preview_title = true,
        },
      }))
      os.execute("mkdir -p ~/.local/share/nvim/databases/")
      require("telescope").load_extension("smart_history")
      require("telescope").load_extension("frecency")
      require("telescope").load_extension("yank_history")
    end,
  },
}
