return {
  "echasnovski/mini.surround",
  opts = {
    n_lines = 100,
    highlight_duration = 1500,
    respect_selection_type = true,
    custom_surroundings = {
      -- Preserves tag attributes. See
      -- https://github.com/echasnovski/mini.nvim/issues/1293#issuecomment-2423827325
      T = {
        -- If this is hard to understand, see
        -- MiniSurround-surround-specification. Basically, the first input
        -- defines a lua pattern for the whole match, and the second defines a
        -- nested pattern where the left part of the match is between the first
        -- two empty captures groups and the right part between the second two.
        -- So here, we're first matching any minimal matching tag pair (as in
        -- the docs, this misses with nested same type tags, but it's close),
        -- then we define the left and right parts as all the word characters
        -- at the beginning of the opening tag and everything inside the
        -- closing tag. In this way, we preserve attributes, if any
        input = { "<(%w+)[^<>]->.-</%1>", "^<()%w+().*</()%w+()>$" },
        output = function()
          local tag_name = MiniSurround.user_input("Tag name")
          if tag_name == nil then
            return nil
          end
          return { left = tag_name, right = tag_name }
        end,
      },
    },
  },
}
