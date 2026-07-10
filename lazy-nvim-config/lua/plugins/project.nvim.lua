return {
  {
    "ahmedkhalf/project.nvim",
    config = function()
      -- project.nvim (not project_nvim) is expected, so we manually run setup
      require("project_nvim").setup({})
    end,
  },
}
