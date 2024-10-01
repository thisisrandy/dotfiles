return {
  "nvim-neo-tree/neo-tree.nvim",
  -- I don't particularly like the default toggle behavior from the default
  -- mappings. Instead of having duplicates, I've instead split it up into
  -- toggle/no toggle variants. The same can always be achieved by just typing
  -- Neotree [toggle] directly
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = false, dir = LazyVim.root() })
      end,
      desc = "Explorer NeoTree (Root Dir, no toggle)",
    },
    {
      "<leader>E",
      function()
        require("neo-tree.command").execute({ toggle = false, dir = vim.uv.cwd() })
      end,
      desc = "Explorer NeoTree (cwd, no toggle)",
    },
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
      end,
      desc = "Explorer NeoTree (Root Dir, toggle)",
    },
    {
      "<leader>fE",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      end,
      desc = "Explorer NeoTree (cwd, toggle)",
    },
  },
}
