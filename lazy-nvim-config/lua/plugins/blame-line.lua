return {
  "braxtons12/blame_line.nvim",
  -- FIXME: This plugin causes hover text to flicker at the top of the screen
  -- before disappearing. I may attempt to hunt down the issue at some point
  enabled = false,
  opts = {
    prefix = "   ",
    delay = 500,
  },
}
