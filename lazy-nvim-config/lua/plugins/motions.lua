return {
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    -- gw conflicts with formatting in visual mode
    opts = { keymaps = { useDefaults = true, disabledDefaults = { "gw" } } },
  },
  {
    "chrisgrieser/nvim-spider",
    lazy = true,
    keys = {
      { mode = { "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", desc = "Spider-w" },
      { mode = { "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", desc = "Spider-e" },
      { mode = { "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", desc = "Spider-b" },
      { mode = { "n", "o", "x" }, "ge", "<cmd>lua require('spider').motion('ge')<CR>", desc = "Spider-ge" },
    },
    -- It's unclear why I have this here. I found a mention of it as a
    -- workaround to some utf8 issues at
    -- https://github.com/chrisgrieser/nvim-spider/issues/14#issuecomment-1631931792,
    -- but it's currently failing to run its config and hanging vim when spider is loaded
    -- for the first time, so I'm going to try doing without it
    -- dependencies = {
    --   "theHamsta/nvim_rocks",
    --   build = "pip3 install --user hererocks && python3 -mhererocks . -j2.1.0-beta3 -r3.0.0 && cp nvim_rocks.lua lua",
    --   config = function()
    --     require("nvim_rocks").ensure_installed("luautf8")
    --   end,
    -- },
  },
}
