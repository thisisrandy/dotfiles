return {
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "UIEnter",
    opts = { useDefaultKeymaps = true },
  },
  {
    "chrisgrieser/nvim-spider",
    lazy = true,
    keys = {
      { mode = { "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", desc = "Spider-w" },
      { mode = { "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", desc = "Spider-e" },
      {
        mode = { "n", "o", "x" },
        "b",
        "<cmd>lua require('spider').motion('b')<CR>",
        desc = "Spider-b",
      },
    },
    dependencies = {
      "theHamsta/nvim_rocks",
      build = "pip3 install --user hererocks && python3 -mhererocks . -j2.1.0-beta3 -r3.0.0 && cp nvim_rocks.lua lua",
      config = function()
        require("nvim_rocks").ensure_installed("luautf8")
      end,
    },
  },
}
