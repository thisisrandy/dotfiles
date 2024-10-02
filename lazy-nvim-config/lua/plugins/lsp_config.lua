return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { mode = "n", "gh", "K", desc = "Hover (synonym for K)", remap = true },
      { mode = "n", "<F2>", "<leader>cr", desc = "Rename", remap = true },
    },
  },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
}
