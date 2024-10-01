return {
  -- I'm currently usring kitty_grab instead of this because of the awkwardness
  -- of https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/273. Should
  -- that be resolved, I may switch back
  -- {
  --   "mikesmithgh/kitty-scrollback.nvim",
  --   enabled = true,
  --   lazy = true,
  --   cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
  --   event = { "User KittyScrollbackLaunch" },
  --   -- version = '*', -- latest stable version, may have breaking changes if major version changed
  --   -- version = '^5.0.0', -- pin major version, include fixes and features that do not have breaking changes
  --   config = function()
  --     require("kitty-scrollback").setup()
  --   end,
  -- },

  {
    "knubie/vim-kitty-navigator",
    build = function()
      local data = vim.fn.stdpath("data")
      os.execute("cp " .. data .. "/lazy/vim-kitty-navigator/*.py ~/.config/kitty/")
    end,
  },
}
