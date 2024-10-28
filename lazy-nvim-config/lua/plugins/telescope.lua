return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- browse plugin files
      {
        "<leader>fp",
        function()
          require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
      -- faster and more familiar file/buffer switching
      { mode = "n", ";", "<leader>,", desc = "Switch buffers", remap = true },
      { mode = "n", "<C-p>", "<leader>ff", desc = "Find files (Root Dir),", remap = true },
    },
    opts = {
      defaults = {
        layout_strategy = "vertical",
      },
    },
  },
}
