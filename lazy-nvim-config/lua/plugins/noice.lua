return {
  "folke/noice.nvim",
  -- NOTE: Per the below, this is likely fragile. If noice starts misbehaving
  -- in future updates, look here first. cmdline_output_to_split is a
  -- completely acceptable alternative.
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
}
