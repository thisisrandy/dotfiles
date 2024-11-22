return {
  {
    "monaqa/dial.nvim",
    opts = function(_, opts)
      local augend = require("dial.augend")

      -- Add a few date/time formats to defaults
      -- FIXME: Dates like "%m/%d/%Y" don't work properly. My initial guess is
      -- that if the format isn't most to least significant then there are
      -- problems. I should file a bug at some point
      vim.list_extend(opts.groups.default, {
        augend.date.alias["%Y-%m-%d"],
        augend.date.alias["%H:%M:%S"],
      })

      -- Add and/or to python
      -- FIXME: This is really a bug. I'll submit a PR later
      if not opts.groups.python then
        opts.groups.python = {}
      end
      table.insert(opts.groups.python, augend.constant.new({ elements = { "and", "or" } }))
      opts.dials_by_ft.python = "python"

      return opts
    end,
  },
}
