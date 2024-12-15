return {
  {
    "monaqa/dial.nvim",
    opts = function(_, opts)
      local augend = require("dial.augend")

      -- Add a few date/time formats to defaults
      -- NOTE: We can introduce a lot of ambiguity with dial formats. The
      -- following three work as expected, but we can't also have e.g.
      -- %m-%d-%Y, because, since we have negative decimals enabled, dial
      -- decides that %d and %Y are standalone negative decimals and not part
      -- of a date
      vim.list_extend(opts.groups.default, {
        augend.date.alias["%m/%d/%Y"],
        augend.date.alias["%Y-%m-%d"],
        augend.date.alias["%H:%M:%S"],
      })

      return opts
    end,
  },
}
