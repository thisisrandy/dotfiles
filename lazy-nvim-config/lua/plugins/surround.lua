return {
  "echasnovski/mini.surround",
  opts = {
    n_lines = 100,
    custom_surroundings = {
      -- Preserves tag attributes. See
      -- https://github.com/echasnovski/mini.nvim/issues/1293#issuecomment-2423827325
      T = {
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
