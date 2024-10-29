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
    },
    opts = {
      defaults = {
        layout_strategy = "vertical",
      },
    },
  },
}
