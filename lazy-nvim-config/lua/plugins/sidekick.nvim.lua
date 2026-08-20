return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      win = {
        -- All of this is pending resolution of
        -- https://github.com/folke/sidekick.nvim/issues/351
        keys = {
          nav_left = {
            "<c-h>",
            function()
              require("kitty-navigator").navigateLeft()
            end,
            expr = true,
            desc = "Move left a Split",
          },
          nav_down = {
            "<c-j>",
            function()
              require("kitty-navigator").navigateDown()
            end,
            expr = true,
            desc = "Move down a Split",
          },
          nav_up = {
            "<c-k>",
            function()
              require("kitty-navigator").navigateUp()
            end,
            expr = true,
            desc = "Move up a Split",
          },
          nav_right = {
            "<c-l>",
            function()
              require("kitty-navigator").navigateRight()
            end,
            expr = true,
            desc = "Move right a Split",
          },
        },
      },
    },
  },
}
