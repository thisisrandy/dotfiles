return {
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
    lazy = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^5.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require("kitty-scrollback").setup()
    end,
  },

  {
    "knubie/vim-kitty-navigator",
    build = function()
      local data = vim.fn.stdpath("data")
      os.execute("cp " .. data .. "/lazy/vim-kitty-navigator/*.py ~/.config/kitty/")
    end,
    keys = {
      { mode = "n", "<c-h>", ":KittyNavigateLeft<cr>", silent = true },
      { mode = "n", "<c-j>", ":KittyNavigateDown<cr>", silent = true },
      { mode = "n", "<c-k>", ":KittyNavigateUp<cr>", silent = true },
      { mode = "n", "<c-l>", ":KittyNavigateRight<cr>", silent = true },
    },
  },
}
