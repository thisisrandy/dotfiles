return {
  {
    "stevearc/aerial.nvim",
    event = "LazyFile",
    ---@param opts table
    opts = function(_, opts)
      opts.layout.max_width = { 80, 0.5 }
      opts.layout.min_width = 30
      opts.layout.resize_to_content = true
      opts.close_automatic_events = { "unsupported" }
      return opts
    end,
  },
}
