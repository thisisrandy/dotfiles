return {
  {
    -- We need to explicitly disable the explorer picker to prevent it from
    -- overriding my mini.files maps when it loads second
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          explorer = function() end,
        },
        sources = {
          -- The notifications picker isn't as functional as I'd like. In
          -- particular, it doesn't wrap long error messages, which seems like
          -- an obvious thing to do, and doesn't provide any of the normal open
          -- in split type functionality that other pickers provide. Wrapping
          -- is easy enough to achieve, but I struggled trying to figure out
          -- how to e.g. open the message in a scratch split for a specific
          -- mapping. This is a good compromise: We just copy the selected
          -- preview contents whenever we close a picker.
          notifications = {
            -- The notifications picker isn't as functional as I'd like. In
            -- particular, it doesn't wrap long error messages, which seems
            -- like an obvious thing to do, and doesn't provide any of the
            -- normal open in split type functionality that other pickers
            -- provide. Wrapping is easy enough to achieve, but I struggled
            -- trying to figure out how to e.g. open the message in a scratch
            -- split for a specific mapping. This is a good compromise: We just
            -- copy the selected preview contents whenever we close a picker.
            confirm = function(picker, item)
              picker:close()
              if item and item.text then
                -- Target the configured copy register
                local target_reg = vim.v.register
                vim.fn.setreg(target_reg, item.text)
                vim.notify("Copied notification to clipboard", vim.log.levels.INFO)
              end
            end,
            win = { preview = { wo = { wrap = true } } },
          },
        },
      },
    },
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
