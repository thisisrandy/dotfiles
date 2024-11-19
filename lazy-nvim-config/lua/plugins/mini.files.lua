return {
  "echasnovski/mini.files",
  keys = {
    {
      "<leader>e",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (Directory of Current File)",
    },
    {
      "<leader>E",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
    {
      "<leader>fm",
      function()
        require("mini.files").open(LazyVim.root(), true)
      end,
      desc = "Open mini.files (root)",
    },
  },
  opts = {
    windows = {
      width_preview = 50,
    },
    options = {
      -- I honestly don't understand what this does, but
      -- https://www.lazyvim.org/extras/editor/mini-files#minifiles says that
      -- it's disabled by default because neo-tree is used by default, so I
      -- guess that means I should have it on...?
      use_as_default_explorer = true,
    },
  },
}
