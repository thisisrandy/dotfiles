return {
  "gregorias/coerce.nvim",
  config = function(_, opts)
    require("coerce").setup(vim.tbl_deep_extend("force", opts, {
      default_mode_keymap_prefixes = {
        normal_mode = "<leader>rw",
        motion_mode = "<leader>rm",
        visual_mode = "<leader>rs",
      },
    }))
    require("which-key").add({
      { mode = { "n", "v" }, "<leader>r", group = "Coe[r]ce" },
      { "<leader>rw", group = "Word" },
      { "<leader>rm", group = "Motion" },
      { mode = "v", "<leader>rs", group = "Selection" },
    })
  end,
}
