return {
  "gbprod/yanky.nvim",
  config = {
    system_clipboard = {
      -- This uses getreg (see get_register_info in utils.lua), which
      -- apparently briefly loses focus when it queries the system clipboard,
      -- which it turn causes gnome to flicker. Based on the defer logic in
      -- system_clipboard.setup(), this is a known issue, so it seems
      -- unlikely to be fixed. In fact, even just "+p causes a flicker. I
      -- think I'm going to just deal with it
      sync_with_ring = true,
      -- When yanky calls its setup function, the clipboard isn't set yet, so
      -- utils.get_system_register returns "*" instead of "+", causing
      -- "clipboard: error: Nothing is copied" when it runs getreg("*") Since I
      -- know I want to use +, I can explicitly set the clipboard register to
      -- bypass the faulty logic
      -- TODO: Figure out why the ordering is wrong. This might be a LazyVim
      -- bug
      -- FIXME: This still happens when there's nothing in +, e.g. at login
      clipboard_register = "+",
    },
  },
}
