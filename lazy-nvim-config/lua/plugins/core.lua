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
  {
    "folke/noice.nvim",
    -- I came to this setup with Gemini's help because noice wasn't displaying
    -- shell output that didn't fall into the long bucket (20 lines). It works
    -- great but is probably way more complicated than it needs to be
    opts = {
      -- 1. Define the customized view with your title and icon
      views = {
        custom_shell_popup = {
          backend = "popup",
          relative = "editor",
          position = "50%",
          enter = true, -- Auto-focuses the window when it appears
          size = {
            width = 80,
            height = "auto",
            max_height = 25,
          },
          border = {
            style = "rounded",
            text = {
              top = "  Shell Output ", -- Your Nerd Font icon and title
              top_align = "left",
            },
          },
          win_options = {
            winhighlight = { Normal = "Normal", Border = "DiagnosticInfo" },
            wrap = true,
          },
        },
      },
      -- 2. Route shell output to your newly created custom view
      routes = {
        {
          view = "custom_shell_popup", -- Tells noice to use the view defined above
          filter = {
            event = "msg_show",
            any = {
              { kind = "shell_out" },
              { kind = "shell_err" },
            },
          },
        },
      },
    },
  },
}
