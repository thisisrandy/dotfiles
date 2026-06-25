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
  -- TODO: The following two have overlap. I think the first of them, maybe
  -- both, can be configured to be the whole package if I want to take the time
  {
    "knubie/vim-kitty-navigator",
    keys = {
      { mode = "n", "<c-h>", ":KittyNavigateLeft<cr>", silent = true },
      { mode = "n", "<c-j>", ":KittyNavigateDown<cr>", silent = true },
      { mode = "n", "<c-k>", ":KittyNavigateUp<cr>", silent = true },
      { mode = "n", "<c-l>", ":KittyNavigateRight<cr>", silent = true },
    },
  },
  {
    "MunsMan/kitty-navigator.nvim",
    build = {
      "cp navigate_kitty.py ~/.config/kitty",
      "cp pass_keys.py ~/.config/kitty",
    },
  },
}
