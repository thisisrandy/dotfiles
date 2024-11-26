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

      -- Add and/or to python
      -- TODO: #4875 was accepted. I can remove this as soon as it's released
      if not opts.groups.python then
        opts.groups.python = {}
      end
      table.insert(opts.groups.python, augend.constant.new({ elements = { "and", "or" } }))
      opts.dials_by_ft.python = "python"

      return opts
    end,
  },
}
