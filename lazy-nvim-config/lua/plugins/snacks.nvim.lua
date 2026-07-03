return {
  {
    -- We need to explicitly disable the explorer picker to prevent it from
    -- overriding my mini.files maps when it loads second
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          explorer = function() end,
        },
      },
    },
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
