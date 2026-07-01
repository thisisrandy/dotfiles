-- Put plugins that need no further configuration here. Otherwise, create a
-- per-plugin or per-plugin group file and store configuration there
return {
  {
    "junegunn/fzf",
    build = ":call fzf#install()",
  },
  { "fladson/vim-kitty" },
  { "andymass/vim-matchup" },
  { -- NOTE: This is on gitlab, not github
    "HiPhish/rainbow-delimiters.nvim",
    config = function(_, opts)
      require("rainbow-delimiters.setup").setup(opts)
      -- With rainbow delimiters on, a fg color change often isn't easily
      -- distinguishable, so we need a stronger visual cue. This is the same
      -- background color used in tokyonight to highlight to object under the
      -- cursor and other instances of it.
      vim.cmd([[highlight MatchParen guibg=#3b4261]])
    end,
  },
  {
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
  },
}
