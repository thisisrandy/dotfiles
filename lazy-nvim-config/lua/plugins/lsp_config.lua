return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { mode = "n", "gh", "K", desc = "Hover (synonym for K)", remap = true },
      { mode = "n", "<F2>", "<leader>cr", desc = "Rename", remap = true },
    },
  },
  { import = "lazyvim.plugins.extras.lang.haskell" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.markdown" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.rust" },
  { import = "lazyvim.plugins.extras.lang.sql" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
}
