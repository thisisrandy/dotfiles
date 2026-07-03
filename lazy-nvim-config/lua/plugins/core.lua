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
    -- I came to this setup with Gemini's help because noice's default settings
    -- (see :NoiceRouters with all this turned off) have a router near the top
    -- that suppresses all event="msg_show" output shorter than 20 lines. The
    -- cmdline_output_to_split preset is really close to what I want, namely
    -- printing all :! output, but I had to do some hacking to get the output
    -- just right and focused after the command is run
    opts = {
      -- 1. Disable the preset so it doesn't fight our ordered route array.
      --    This is the default and thus unnecessary, but we'll leave it here
      --    to document
      presets = {
        cmdline_output_to_split = false,
      },
      -- 2. Define our custom layout views
      views = {
        -- Custom clone view explicitly for shell outputs with our newline tweak
        shell_split_output = {
          view = "split",
          enter = true,
          format = "shell_details", -- Tells this view to use our custom format style
        },
      },
      -- 3. Isolate the newline format tweak to its own style block
      format = {
        shell_details = {
          "{level} ",
          "{date} ",
          "{event}",
          { "{kind}", before = { ".", hl_group = "NoiceFormatKind" } },
          " ",
          "{title} ",
          "{cmdline} ",
          { "\n", count = 1 }, -- Isolated here safely
          "{message}",
        },
      },
      -- 4. MANUALLY ORDERED ROUTES (Fixes the sequencing completely)
      routes = {
        -- Route A: Drop the shell command repetition echo first
        {
          filter = { kind = "shell_cmd" },
          opts = { skip = true },
        },
        -- Route B: Send ALL shell outputs to our custom formatted split layout
        {
          filter = {
            event = "msg_show",
            any = {
              { kind = "shell_out" },
              { kind = "shell_err" },
            },
          },
          view = "shell_split_output",
        },
        -- Route C: Make sure the route to suppress short output is next. Its
        -- ordering gets messed up when we try to customize the routes, so
        -- output from e.g. :w is also displayed without this
        {
          filter = { event = "msg_show", min_height = 20 },
          view = "cmdline_output",
        },
      },
    },
  },
}
