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
          -- how to set specific mappings. This is a good compromise: Always
          -- open the message contents in a scratch split on confirm
          notifications = {
            confirm = function(picker, item)
              picker:close()
              if item and item.text then
                -- I was previously copying the message to the clipboard on confirm
                -- -- Target the configured copy register
                -- local target_reg = vim.v.register
                -- vim.fn.setreg(target_reg, item.text)
                -- vim.notify("Copied notification to clipboard", vim.log.levels.INFO)

                -- Instead, we'll open it in a scratch split
                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_open_win(buf, true, {
                  split = "below",
                  height = 15,
                })
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(item.text, "\n"))
                vim.api.nvim_win_set_buf(0, buf)
                vim.keymap.set("n", "q", function()
                  vim.api.nvim_win_close(0, false)
                end, { buffer = 0 })
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
