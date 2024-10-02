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
      -- Under cursor grep shortcuts.
      -- Note that the following don't account for special regex chars in any way.
      -- Copied text has the potential to be a malformed expression
      {
        mode = "n",
        "<leader>su",
        '"zyiw<leader>sg<c-r>z',
        desc = "Grep for word [u]nder cursor (Root Dir),",
        remap = true,
      },
      {
        mode = "n",
        "<leader>sU",
        '"zyiw<leader>sG<c-r>z',
        desc = "Grep for word [U]nder cursor (cwd),",
        remap = true,
      },
      {
        mode = "v",
        "<leader>su",
        '"zy<leader>sg<c-r>z',
        desc = "Grep for highlighted word ([u]nder cursor), (Root Dir),",
        remap = true,
      },
      {
        mode = "v",
        "<leader>sU",
        '"zy<leader>sG<c-r>z',
        desc = "Grep for highlighted word ([U]nder cursor), (cwd),",
        remap = true,
      },
    },
    opts = {
      defaults = {
        layout_strategy = "vertical",
      },
    },
  },
}
