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
    },
  },
}
