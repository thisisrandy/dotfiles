return {
  "jiaoshijie/undotree",
  dependencies = "nvim-lua/plenary.nvim",
  config = true,
  lazy = true,
  keys = { -- load the plugin only when using it's keybinding:
    { "<leader>o", "<cmd>lua require('undotree').toggle()<cr>", desc = "Open und[o]tree" },
  },
}
