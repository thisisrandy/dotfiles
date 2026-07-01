return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      -- See https://cmp.saghen.dev/configuration/keymap#super-tab
      preset = "super-tab",
      -- super-tab doesn't disable blink's default Enter functionality. This
      -- is super annoying when we actually want a new line, so we disable it
      -- explicitly
      ["<CR>"] = {},
    },
  },
}
